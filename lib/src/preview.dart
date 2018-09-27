import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

import 'controller.dart';
import 'types.dart';

class _ImagePreview<T> extends StatelessWidget {
  const _ImagePreview({
    Key key,
    @required this.image,
    @required this.previewImageBuilder,
    this.onRemove,
  }) : super(key: key);

  final T image;
  final VoidCallback onRemove;
  final BuildImagePreviewCallback<T> previewImageBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          previewImageBuilder(context, image),
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

class ImagesPreview<T> extends StatefulWidget {
  const ImagesPreview({
    @required this.controller,
    @required this.previewImageBuilder
  });

  final ImageFieldController<T> controller;
  final BuildImagePreviewCallback<T> previewImageBuilder;

  @override
  _ImagesPreviewState<T> createState() => _ImagesPreviewState<T>();
}

class _ImagesPreviewState<T> extends State<ImagesPreview> {
  List<T> images;

  Widget buildImage(T image) {
    if (image == null) return Container();

    return _ImagePreview<T>(
        image: image,
        previewImageBuilder: widget.previewImageBuilder,
        onRemove: () => widget.controller.remove(image));
  }

  @override
  Widget build(BuildContext context) {
    if (images == null || images.isEmpty) return Container();

    return Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: images.length == 1
            ? SizedBox(child: buildImage(images.first))
            : SizedBox(
                height: 150.0,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10.0, crossAxisCount: 1),
                  itemCount: images.length,
                  itemBuilder: (_, idx) => buildImage(images[idx]),
                  scrollDirection: Axis.horizontal,
                )));
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
    _setImages();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_setImages);
    super.dispose();
  }
}
