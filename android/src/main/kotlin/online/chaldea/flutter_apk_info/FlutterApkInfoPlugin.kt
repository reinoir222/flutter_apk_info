package online.chaldea.flutter_apk_info

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterApkInfoPlugin */
class FlutterApkInfoPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var context: Context
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_apk_info")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getApkInfo") {
      val filePath = call.argument<String>("archiveFilePath")

      if (filePath == null) {
        result.error("Invalid", "archiveFilePath must not be null", null)
        return
      }

      val pm: PackageManager = context.packageManager
      val info = pm.getPackageArchiveInfo(filePath, 0)

      if (info == null) {
        result.error("Invalid", "Package parse error", filePath)
        return
      }

      val map: MutableMap<String, String> = HashMap()
      map["appName"] = info.applicationInfo?.loadLabel(pm)?.toString() ?: "Unknown App"
      map["packageName"] = info.packageName ?: ""
      map["version"] = info.versionName ?: ""
      map["buildNumber"] = getLongVersionCode(info).toString()

      result.success(map)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  companion object {
    @JvmStatic
    fun getLongVersionCode(info: PackageInfo): Long {
      return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        info.longVersionCode
      } else info.versionCode.toLong()
    }
  }
}
