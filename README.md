# image_native_resizer

[![pub package](https://img.shields.io/pub/v/image_native_resizer.svg)](https://pub.dartlang.org/packages/image_native_resizer)

A Flutter plugin that resizes images from native API, while keeping important EXIF attributes.

## Installation

First, add `image_native_resizer` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Quickstart

``` dart
import 'package:image_native_resizer/image_native_resizer.dart';

final localImagePath = /*** ***/;
final resizedPath = await ImageNativeResizer.resize(
    imagePath: localImagePath,
    maxWidth: 512,
    maxHeight: 512,
    quality: 50,
);
```

## Inspired by `image_picker`

This plugin is almost identitical to the official [image_picker](https://github.com/flutter/plugins/tree/master/packages/image_picker/image_picker) plugin. Serveral internal files from the plugin are used to implement the resizing logic, this plugin is just exposing them through a platform channel.
