import 'dart:async';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApkInfo extends PackageInfo {
  ApkInfo({
    required super.appName,
    required super.packageName,
    required super.version,
    required super.buildNumber
  });

  static const MethodChannel _channel = const MethodChannel('flutter_apk_info');

  static Future<ApkInfo> fromPath(String path) {
    return _channel.invokeMapMethod('getApkInfo', {
      "archiveFilePath": path,
    }).then<ApkInfo>((map) {
      map!;
      return ApkInfo(
        appName: map["appName"],
        packageName: map["packageName"]!,
        version: map["version"]!,
        buildNumber: map["buildNumber"]!,
      );
    });
  }
}
