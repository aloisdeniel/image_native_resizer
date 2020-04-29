import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageNativeResizer {
  static const MethodChannel _channel =
      const MethodChannel('image_native_resizer');

  static Future<String> resize({
    @required String imagePath,
    double maxWidth,
    double maxHeight,
    int quality,
  }) async {
    final path = await _channel.invokeMethod('resize', {
      'imagePath': imagePath,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'quality': quality,
    });
    return path;
  }
}
