import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApkInfo extends PackageInfo {
  Uint8List? iconData;
  ApkInfo({
    required super.appName,
    required super.packageName,
    required super.version,
    required super.buildNumber,
    this.iconData
  });

  static const MethodChannel _channel = const MethodChannel('flutter_apk_info');

  static Future<ApkInfo> fromPath(String path) {
    return _channel.invokeMapMethod('getApkInfo', {
      "archiveFilePath": path,
    }).then<ApkInfo>((map) {
      map!;
      print("icon: ${map["iconData"]}");
      return ApkInfo(
        appName: map["appName"],
        packageName: map["packageName"]!,
        version: map["version"]!,
        buildNumber: map["buildNumber"]!,
        iconData: map["iconData"] is String ? _decodeBase64Icon(map['iconData']) : null
      );
    });
  }

  static Uint8List? _decodeBase64Icon(String? base64String) {
    if (base64String == null) return null;
    try {
      return base64.decode(base64String);
    } catch (e) {
      print("Base64解码失败: $e");
      return null;
    }
  }
}
