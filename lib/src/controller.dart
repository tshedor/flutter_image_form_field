import 'package:flutter/widgets.dart';

class ImageingController<T> extends ValueNotifier<List<T>> {
  ImageingController(this.value) : super(value);

  /// Creates a controller for an editable image field from an initial value.
  ImageingController.fromValue(List<T> value)
    : super(value ?? List<T>());

  List<T> value;

  /// Set the controller to only contain this image
  addDestructively(T image) {
    value.clear();
    value.add(image);
    notifyListeners();
  }

  /// Add image to controller
  add(T image) {
    value.add(image);
    notifyListeners();
  }

  /// Remove specific image from controller
  remove(T image) {
    value.remove(image);
    notifyListeners();
  }

  /// Reset controller's value
  clear() {
    value.clear();
    notifyListeners();
  }

  resetTo(List<T> images) {
    value = images;
    notifyListeners();
  }
}
