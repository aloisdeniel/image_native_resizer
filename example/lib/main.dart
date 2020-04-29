import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart';
import 'package:image_native_resizer/image_native_resizer.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Not started';
  File _sampleFile;
  List<String> resized = [];
  List<String> exif = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> downloadSampleImageIfNeeded() async {
    final localDirectory = await getApplicationDocumentsDirectory();
    _sampleFile = File(path.join(localDirectory.path, 'sample.jpeg'));
    if (!await _sampleFile.exists()) {
      final client = http.Client();
      final bytes = await client.readBytes(
          'https://github.com/ianare/exif-samples/raw/master/jpg/gps/DSCN0029.jpg');
      await _sampleFile.writeAsBytes(bytes);
    }

    Map<String, IfdTag> data =
        await readExifFromBytes(await _sampleFile.readAsBytes());
    exif.add(data.entries.map((x) => "${x.key} = ${x.value}").join(' | '));
  }

  Future<void> resize({double maxWidth, double maxHeight, int quality}) async {
    var resizedPath = await ImageNativeResizer.resize(
      imagePath: _sampleFile.path,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
    final copyPath = path.join(path.dirname(resizedPath),
        '${resized.length}${path.extension(resizedPath)}');
    await File(resizedPath).copy(copyPath);
    resized.add(copyPath);
    Map<String, IfdTag> data =
        await readExifFromBytes(await File(copyPath).readAsBytes());
    exif.add(data.entries.map((x) => "${x.key} = ${x.value}").join(' | '));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await downloadSampleImageIfNeeded();
    if (!mounted) return;
    this.setState(() => _status = 'Sample file downloaded');
    print('_sampleFile: ${_sampleFile?.path}');

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await resize(maxWidth: 312);
      if (!mounted) return;
      this.setState(() => _status = 'smallWidth loaded');

      await resize(maxHeight: 312);
      if (!mounted) return;
      this.setState(() => _status = 'smallHeight loaded');

      await resize(quality: 2);
      if (!mounted) return;
      this.setState(() => _status = 'All loaded');
    } on PlatformException {
      _status = 'Failed to call platform plugin.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: [
              Text('Running on: $_status\n'),
              if (_sampleFile != null) ...[
                Text(exif[0]),
                Image.file(
                  File(_sampleFile.path),
                ),
              ],
              if (resized.isNotEmpty)
                ...List.generate(
                  resized.length,
                  (x) => <Widget>[
                    SizedBox(
                      height: 24,
                    ),
                    Text(exif[x + 1]),
                    Image.file(
                      File(resized[x]),
                    ),
                  ],
                ).expand((e) => e),
            ],
          ),
        ),
      ),
    );
  }
}
