import 'package:flutter/material.dart';

import 'package:image_form_field/image_form_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'upload_button.dart';
import 'image_input_adapter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Image Demo',
      home: new MyHomePage(),
    );
  }
}

class BlogImage {
  const BlogImage({
    @required this.storagePath,
    @required this.originalUrl,
    @required this.bucketName,
    this.id
  });

  final String storagePath;
  final String originalUrl;
  final String bucketName;
  final String id;

  static String get collectionPath => "blogImages";

  create() {
    return Firestore.instance.collection(collectionPath).document().setData({
      "storagePath" : storagePath,
      "originalUrl" : originalUrl,
      "bucketName" : bucketName
    });
  }

  static Future<BlogImage> fromUrl(String url) async {
    final images = await Firestore.instance.collection(collectionPath)
      .where("originalUrl", isEqualTo: url)
      .getDocuments();

    if (images.documents.isNotEmpty) {
      final i = images.documents.first.data;

      return BlogImage(
        storagePath: i["storagePath"],
        originalUrl: i["originalUrl"],
        bucketName: i["bucketName"],
        id: images.documents.first.documentID
      );
    }

    return null;
  }

  Future delete() async {
    FirebaseStorage.instance.ref().child(storagePath).delete();
    return Firestore.instance.collection(collectionPath).document(id).delete();
  }
}

class _UploadForm extends StatefulWidget {
  _UploadForm(
    this.existingImages
  );

  final List<BlogImage> existingImages;

  @override
  State<StatefulWidget> createState() => _UploadFormState();
}

class _UploadFormState extends State<_UploadForm> {
  final _formKey = GlobalKey<FormState>();
  List<ImageInputAdapter> _images;

  void submit() {
    if( _formKey.currentState.validate() ) {
      _formKey.currentState.save();
      var snackbarText = "Upload successful";

      try {
        // New images
        _images
          ?.where((i) => i.isFile)
          ?.forEach((i) async {
            final photo = await i.save();

            BlogImage(
              storagePath: photo.refPath,
              originalUrl: photo.originalUrl,
              bucketName: photo.bucketName
            ).create();
          });

        // Removed images
        widget.existingImages
          ?.where((r) =>
            !_images.any((m) => m.url == r.originalUrl)
          )
          ?.forEach((i) {
            BlogImage.fromUrl(i.originalUrl).then((b) => b?.delete());
          });

      } catch(e) {
        print(e);
        snackbarText = "Couldn't save. Please try again later.";
      } finally {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarText)
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldAllowMultiple = true;

    return Form(
      key: _formKey,
      child: ListBody(
        children: [
          ImageFormField<ImageInputAdapter>(
            shouldAllowMultiple: shouldAllowMultiple,
            onSaved: (val) => _images = val,
            initialValue: widget.existingImages.map((i) => ImageInputAdapter(url: i.originalUrl)).toList().cast<ImageInputAdapter>(),
            initializeFileAsImage: (file) =>
              ImageInputAdapter(file: UploadableImage(file, storagePath: "appImages")),
            buttonBuilder: (_, count) =>
              PhotoUploadButton(
                count: count,
                shouldAllowMultiple: shouldAllowMultiple
              ),
            previewImageBuilder: (_, image) => image.widgetize()
          ),
          FlatButton(
            onPressed: submit,
            child: const Text("Update Profile")
          )
        ]
      )
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Upload Images")
      ),
      body: SingleChildScrollView(
        // Provide existing images as the first argument
        child: _UploadForm(List<BlogImage>())
      ),
    );
  }
}
