import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:image_form_field/image_form_field.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'upload_button.dart';
import 'image_input_adapter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Demo',
      home: MyHomePage(),
    );
  }
}

class BlogImage {
  const BlogImage({
    required this.storagePath,
    required this.originalUrl,
    required this.bucketName,
    this.id,
  });

  final String storagePath;
  final String originalUrl;
  final String bucketName;
  final String? id;

  static String get collectionPath => 'blogImages';

  Future<void> create() {
    return FirebaseFirestore.instance.collection(collectionPath).doc().set({
      'storagePath': storagePath,
      'originalUrl': originalUrl,
      'bucketName': bucketName,
    });
  }

  static Future<BlogImage?> fromUrl(String url) async {
    final images = await FirebaseFirestore.instance
        .collection(collectionPath)
        .where('originalUrl', isEqualTo: url)
        .get();

    if (images.docs.isNotEmpty) {
      final i = images.docs.first.data();

      return BlogImage(
        storagePath: i?['storagePath'],
        originalUrl: i?['originalUrl'],
        bucketName: i?['bucketName'],
        id: images.docs.first.id,
      );
    }

    return null;
  }

  Future delete() async {
    await FirebaseStorage.instance.ref().child(storagePath).delete();
    return FirebaseFirestore.instance.collection(collectionPath).doc(id).delete();
  }
}

class _UploadForm extends StatefulWidget {
  _UploadForm(this.existingImages);

  final List<BlogImage> existingImages;

  @override
  State<StatefulWidget> createState() => _UploadFormState();
}

class _UploadFormState extends State<_UploadForm> {
  final _formKey = GlobalKey<FormState>();
  List<ImageInputAdapter>? _images;

  void submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      var snackbarText = 'Upload successful';

      try {
        // New images
        _images?.where((i) => i.isFile).forEach((i) async {
          final photo = await i.save();

          await BlogImage(
            storagePath: photo.refPath,
            originalUrl: photo.originalUrl,
            bucketName: photo.bucketName,
          ).create();
        });

        // Removed images
        widget.existingImages
            .where((r) => !(_images?.any((m) => m.url == r.originalUrl) ?? false))
            .forEach((i) {
          BlogImage.fromUrl(i.originalUrl).then((b) => b?.delete());
        });
      } catch (e) {
        print(e);
        snackbarText = "Couldn't save. Please try again later.";
      } finally {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackbarText)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldAllowMultiple = true;

    return Form(
      key: _formKey,
      child: ListBody(
        children: [
          ImageFormField<ImageInputAdapter>(
            shouldAllowMultiple: shouldAllowMultiple,
            onSaved: (val) => _images = val,
            initialValue: widget.existingImages
                .map((i) => ImageInputAdapter(url: i.originalUrl))
                .toList()
                .cast<ImageInputAdapter>(),
            initializeFileAsImage: (file) => ImageInputAdapter(
              file: UploadableImage(
                file,
                storagePath: 'appImages',
              ),
            ),
            buttonBuilder: (_, count) =>
                PhotoUploadButton(count: count, shouldAllowMultiple: shouldAllowMultiple),
            previewImageBuilder: (_, image) => image.widgetize(),
          ),
          TextButton(
            onPressed: submit,
            child: const Text('Update Profile'),
          )
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Upload Images')),
      body: SingleChildScrollView(
        // Provide existing images as the first argument
        child: _UploadForm(<BlogImage>[]),
      ),
    );
  }
}
