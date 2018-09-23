import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageInputAdapter {
  /// Initialize from either a URL or a file, but not both.
  ImageInputAdapter({
    this.file,
    this.url
  }) : assert(file != null || url != null), assert(file != null && url == null), assert(file == null && url != null);

  /// An image file
  final UploadableImage file;
  /// A direct link to the remote image
  final String url;

  /// If instance was initialized with a file
  bool get isFile => file != null;
  /// If instance was initialized with a URL
  bool get isUrl => url != null;

  /// Render the image from a file or from a remote source.
  Widget widgetize() {
    if (file != null) {
      return Image.file(file.image);
    } else {
      return FadeInImage(
        image: NetworkImage(url),
        placeholder: AssetImage("assets/images/placeholder.png"),
        fit: BoxFit.contain,
      );
    }
  }

  /// Upload the file to FirebaseStorage
  Future<UploadResponse> save() => file?.save();
}


class UploadResponse {
  UploadResponse({
    @required this.refPath,
    @required this.originalUrl,
    @required this.bucketName
  });

  /// Firebase storage reference path
  final String refPath;

  /// Firebase storage download url unedited by any post-upload functions
  final String originalUrl;

  /// Firebase storage bucket
  final String bucketName;
}

class UploadableImage {
  UploadableImage(
    this.image,
    {
      @required this.storagePath
    }
  );

  /// Input file
  final File image;
  /// FirebaseStorage folder name
  final String storagePath;

  // s/o https://github.com/mdanics/fluttergram/blob/master/lib/upload_page.dart#L224
  /// Save image to FirebaseStorage bucket
  Future<UploadResponse> save() async {
    final uuid = new Uuid().v1();
    final _refPath = "$storagePath/$uuid.jpg";
    StorageReference ref = FirebaseStorage.instance.ref().child(_refPath);
    StorageUploadTask uploadTask = ref.putFile(image);
    final _uploaded = await uploadTask.future;
    final _bucketName = await ref.getBucket();

    return UploadResponse(
      refPath: _refPath,
      originalUrl: _uploaded.downloadUrl.toString(),
      bucketName: _bucketName
    );
  }
}
