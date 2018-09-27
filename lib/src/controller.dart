import 'package:flutter/foundation.dart';

/// An observer used in conjunction with the [ImageFormField].
///   This controller's primary purpose is to update images displayed
///   in [ImagesPreview] and to submit a value when the [Form] is saved.
class ImageFieldController<T> extends ValueNotifier<List<T>> {
  ImageFieldController(this.value) : super(value);

  /// Creates a controller for an editable image field from an initial value.
  ImageFieldController.fromValue(List<T> value) : super(value ?? List<T>());

  List<T> value;

  /// Set the controller to only contain this image
  addDestructively(T image) {
    value.clear();
    value.add(image);
    notifyListeners();
  }

  /// Add an image to the controller.
  /// The new image is inserted at the beginning of the list
  ///   because it is the most recent.
  add(T image) {
    value.insert(0, image);
    notifyListeners();
  }

  /// Remove specific image from the controller.
  remove(T image) {
    value.remove(image);
    notifyListeners();
  }

  /// Reset the controller's value.
  clear() {
    value.clear();
    notifyListeners();
  }

  /// Set the controller to a new value.
  resetTo(List<T> images) {
    value = images;
    notifyListeners();
  }
}
