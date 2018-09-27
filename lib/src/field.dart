import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'button.dart';
import 'preview.dart';
import 'types.dart';

/// A [FormField] that contains an [ImageField].
///
/// This is a convenience widget that wraps an [ImageField] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
class ImageFormField<T extends Object> extends FormField<List<T>> {
  ImageFormField(
      {Key key,
      this.controller,
      @required BuildImagePreviewCallback<T> previewImageBuilder,
      @required BuildButton buttonBuilder,
      @required InitializeFileAsImageCallback<T> initializeFileAsImage,
      List<T> initialValue,
      FormFieldSetter<List<T>> onSaved,
      FormFieldValidator<List<T>> validator,
      TextStyle errorTextStyle,
      bool autovalidate = false,
      bool shouldAllowMultiple = true})
      : assert(autovalidate != null),
        super(
          key: key,
          initialValue: controller != null
              ? controller.value
              : (initialValue ?? List<T>()),
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          builder: (FormFieldState<List<T>> field) {
            final _ImageFormFieldState<T> state = field;

            return ListBody(children: [
              ImageButton<T>(
                controller: state._effectiveController,
                buttonBuilder: buttonBuilder,
                initializeFileAsImage: initializeFileAsImage,
                shouldAllowMultiple: shouldAllowMultiple,
              ),
              field.hasError
                  ? Text(
                      field.errorText,
                      style: errorTextStyle,
                    )
                  : Container(),
              ImagesPreview<T>(
                controller: state._effectiveController,
                previewImageBuilder: previewImageBuilder,
              )
            ]);
          },
        );

  /// Controls the images being edited.
  final ImageFieldController<T> controller;

  @override
  _ImageFormFieldState<T> createState() => new _ImageFormFieldState<T>();
}

// Adapted from [TextFormField]
class _ImageFormFieldState<T> extends FormFieldState<List<T>> {
  ImageFieldController<T> _controller;

  ImageFieldController<T> get _effectiveController =>
      widget.controller ?? _controller;

  @override
  ImageFormField<T> get widget => super.widget;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = new ImageFieldController<T>(widget.initialValue);
    } else {
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(ImageFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null)
        _controller =
            new ImageFieldController<T>.fromValue(oldWidget.controller.value);
      if (widget.controller != null) {
        setValue(widget.controller.value);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.clear();
      _effectiveController.resetTo(widget.initialValue);
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.value != value)
      didChange(_effectiveController.value);
  }
}
