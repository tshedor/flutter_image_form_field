import 'dart:io' show File;
import 'package:flutter/widgets.dart' show Widget, BuildContext;

typedef BuildImagePreviewCallback<T> = Widget Function(BuildContext, dynamic);
typedef BuildButton = Widget Function(BuildContext, int);
typedef InitializeFileAsImageCallback<T> = T Function(File);
