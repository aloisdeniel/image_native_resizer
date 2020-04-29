import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageNativeResizer {
  static const MethodChannel _channel =
      const MethodChannel('image_native_resizer');

  /// Resizes the image at the given [imagePath] to the given
  /// [maxWidth], [maxHeight] and/or [quality].
  ///
  /// If the image size is smaller than the provided [maxWidth] and/or
  /// [maxHeight], the original image can be returned.
  ///
  /// The [quality] must be a value between `0` and `100`.
  static Future<String> resize({
    @required String imagePath,
    double maxWidth,
    double maxHeight,
    int quality,
  }) async {
    assert(imagePath != null);
    assert(quality == null || (quality >= 0 && quality <= 100));
    final path = await _channel.invokeMethod('resize', {
      'imagePath': imagePath,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'quality': quality,
    });
    return path;
  }
}
