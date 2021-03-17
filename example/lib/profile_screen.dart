import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_form_field/image_form_field.dart';

import 'image_input_adapter.dart';
import 'upload_button.dart';

class _ProfileForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  List<ImageInputAdapter>? _images;

  void submit(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final uploadedFile = _images?.firstWhere((i) => i.isFile);

      if (uploadedFile != null) {
        final resp = await uploadedFile.save();
        await FirebaseAuth.instance.currentUser?.updateProfile(photoURL: resp.originalUrl);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lookin' good!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please sign in'));

    return Form(
      key: _formKey,
      child: ListBody(
        children: [
          ImageFormField<ImageInputAdapter>(
            shouldAllowMultiple: false,
            onSaved: (val) => _images = val,
            initialValue: user.photoURL == null ? null : [ImageInputAdapter(url: user.photoURL)],
            initializeFileAsImage: (file) => ImageInputAdapter(
              file: UploadableImage(file, storagePath: 'profileImages'),
            ),
            buttonBuilder: (_, count) => PhotoUploadButton(
              count: count,
              shouldAllowMultiple: false,
            ),
            previewImageBuilder: (_, image) => image.widgetize(),
          ),
          TextButton(
            onPressed: () => submit(context),
            child: const Text('Update Profile'),
          )
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: _ProfileForm(),
      ),
    );
  }
}
