import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_apk_info/flutter_apk_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _reading = false;
  ApkInfo? _info;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadApk(String path) async {
    ApkInfo? info;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      setState(() {
        _reading = true;
      });
      info = await ApkInfo.fromPath(path);
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _info = info;
      _reading = false;
    });
  }

  Widget buildMain(BuildContext context) {
    if (_reading){
      return CircularProgressIndicator();
    }
    if (_info == null) {
      return Text('Please select an .apk file.');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_info!.iconData is Uint8List) Image.memory(_info!.iconData!, width: 64,),
        Text('APK Info', style: TextStyle(fontWeight: FontWeight.bold),),
        Text(
            "appName = ${_info?.appName}\n"
            "packageName = ${_info?.packageName}\n"
            "version = ${_info?.version}\n"
            "buildNumber = ${_info?.buildNumber}\n"
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterApkInfo Example'),
        ),
        body: Center(
          child: buildMain(context)
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                print(result.files.single);
                if (result.files.single.path != null) {
                  loadApk(result.files.single.path!);
                }
              }
            },
            child: Icon(Icons.file_open),
        ),
      ),
    );
  }
}
