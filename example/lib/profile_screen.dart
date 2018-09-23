import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_form_field/image_form_field.dart';

import 'image_input_adapter.dart';
import 'upload_button.dart';

class _ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  List<ImageInputAdapter> _images;
  FirebaseUser _user;
  bool _doesUserExist = true;

  void submit() {
    if( _formKey.currentState.validate() ) {
      _formKey.currentState.save();
      var newInfo = new UserUpdateInfo();
      final uploadedFile = _images.firstWhere((i) => i.isFile, orElse: () => null);

      if ( uploadedFile != null ) {
        uploadedFile.save().then((resp) {
          newInfo.photoUrl = resp.originalUrl;
        });
      }

      FirebaseAuth.instance.updateProfile(newInfo)
        .then((u) {
          Scaffold.of(context).showSnackBar(
            const SnackBar(
              content: const Text("Lookin' good!")
            )
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_doesUserExist) return const Center(child: const Text("Please sign in"));

    if (_user == null) return const Center(child: CircularProgressIndicator());

    final bool shouldAllowMultiple = false;

    return Form(
      key: _formKey,
      child: ListBody(
        children: [
          ImageFormField<ImageInputAdapter>(
            shouldAllowMultiple: shouldAllowMultiple,
            onSaved: (val) => _images = val,
            initialValue: _user?.photoUrl == null
              ? null
              : (List<ImageInputAdapter>()..add(ImageInputAdapter(url: _user.photoUrl))),
            initializeFileAsImage: (file) =>
              ImageInputAdapter(file: UploadableImage(file, storagePath: "profileImages")),
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

  _fetchUser() async {
    final user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      return setState(() {
        _doesUserExist = false;
      });
    }

    setState(() {
      _user = user;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUser();
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        child: _ProfileForm()
      )
    );
  }
}
