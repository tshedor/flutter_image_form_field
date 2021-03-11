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
  ImageFormField({
    Key? key,
    this.controller,
    required BuildImagePreviewCallback<T> previewImageBuilder,
    required BuildButton buttonBuilder,
    required InitializeFileAsImageCallback<T> initializeFileAsImage,
    List<T>? initialValue,
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    TextStyle? errorTextStyle,
    AutovalidateMode? autovalidateMode,
    bool shouldAllowMultiple = true,
  }) : super(
          key: key,
          initialValue: controller != null ? controller.value : (initialValue ?? <T>[]),
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<List<T>> field) {
            final state = field as _ImageFormFieldState<T>;

            return ListBody(
              children: [
                if (state._effectiveController != null)
                  ImageButton<T>(
                    controller: state._effectiveController!,
                    buttonBuilder: buttonBuilder,
                    initializeFileAsImage: initializeFileAsImage,
                    shouldAllowMultiple: shouldAllowMultiple,
                  ),
                field.hasError
                    ? Text(
                        field.errorText ?? '',
                        style: errorTextStyle,
                      )
                    : Container(),
                if (state._effectiveController != null)
                  ImagesPreview<T>(
                    controller: state._effectiveController!,
                    previewImageBuilder: previewImageBuilder,
                  )
              ],
            );
          },
        );

  /// Controls the images being edited.
  final ImageFieldController<T>? controller;

  @override
  _ImageFormFieldState<T> createState() => _ImageFormFieldState<T>();
}

// Adapted from [TextFormField]
class _ImageFormFieldState<T extends Object> extends FormFieldState<List<T>> {
  ImageFieldController<T>? _controller;

  ImageFieldController<T>? get _effectiveController =>
      (widget as ImageFormField<T>).controller ?? _controller!;

  @override
  ImageFormField<T> get _widget => widget as ImageFormField<T>;

  @override
  void initState() {
    super.initState();
    if (_widget.controller == null && _widget.initialValue != null) {
      _controller = ImageFieldController<T>(_widget.initialValue!);
    } else {
      _widget.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(ImageFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _widget.controller == null) {
        _controller = ImageFieldController<T>(oldWidget.controller!.value);
      }
      if (_widget.controller != null) {
        setValue(_widget.controller!.value);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  @override
  void dispose() {
    _widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController?.clear();
      if (widget.initialValue != null) _effectiveController?.resetTo(widget.initialValue!);
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
    if (_effectiveController?.value != value) didChange(_effectiveController?.value);
  }
}
