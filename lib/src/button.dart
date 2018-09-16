import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'controller.dart';

class ImageButton<I> extends StatelessWidget {
  ImageButton({
    Key key,
    @required this.controller,
    @required this.uploadImage,
    @required this.child,
    this.shouldAllowMultiple = true
  }) : super( key : key );

  final ImageingController controller;
  final Widget child;
  final I Function(File) uploadImage;
  final bool shouldAllowMultiple;

  Future getImage(ImageSource source) async {
    final image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      final newImage = uploadImage(image);

      if (shouldAllowMultiple) {
        controller.add(newImage);
      } else {
        controller.addDestructively(newImage);
      }
    }
  }

  _handlePressed(BuildContext ctx) {
    showModalBottomSheet(context: ctx, builder: (BuildContext context) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          new ListTile(
            leading: new Icon(Icons.camera_alt),
            title: new Text('Take a Picture'),
            onTap: () {
              getImage(ImageSource.camera);
              Navigator.pop(context);
            }
          ),
          new ListTile(
            leading: new Icon(Icons.photo_library),
            title: new Text('Camera Roll'),
            onTap: () {
              getImage(ImageSource.gallery);
              Navigator.pop(context);
            }
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => _handlePressed(context),
      child: child
    );
  }
}
