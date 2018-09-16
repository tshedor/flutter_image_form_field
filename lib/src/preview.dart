import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

import 'controller.dart';
import 'types.dart';

class _ImageImagePreview<T> extends StatelessWidget {
  const _ImageImagePreview({
    Key key,
    @required this.image,
    @required this.previewImageBuilder,
    this.onRemove,
  }) : super(key : key);

  final T image;
  final VoidCallback onRemove;
  final BuildImagePreviewCallback<T> previewImageBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          previewImageBuilder(image),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              color: const Color(0xFFFFFFFF)
            )
          )
        ]
      )
    );
  }
}

class ImagePreview<I> extends StatefulWidget {
  const ImagePreview({
    @required this.controller,
    @required this.previewImageBuilder
  });

  final ImageingController<I> controller;
  final BuildImagePreviewCallback<I> previewImageBuilder;

  @override
  _ImagePreviewState<I> createState() => _ImagePreviewState<I>();
}

class _ImagePreviewState<I> extends State<ImagePreview> {
  List<I> images;

  Widget buildImage(I image) {
    if (image == null)
      return Container();

    return _ImageImagePreview<I>(
      image: image,
      previewImageBuilder: widget.previewImageBuilder,
      onRemove: () => widget.controller.remove(image)
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images == null)
      return Container();

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: images.length == 1
        ? SizedBox( child: buildImage(images.first) )
        : SizedBox(
            height: 150.0,
            child: GridView.count(
              crossAxisCount: 1,
              mainAxisSpacing: 10.0,
              children: images.reversed.map(buildImage).toList(),
              scrollDirection: Axis.horizontal,
            )
          )
    );
  }

  void _setImages() {
    setState(() {
      images = widget.controller.value;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_setImages);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_setImages);
  }
}
