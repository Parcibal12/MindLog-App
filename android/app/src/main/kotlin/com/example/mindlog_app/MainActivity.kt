package com.example.mindlog_app

import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.mindlog.device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceName" -> {
                    val manufacturer = Build.MANUFACTURER
                    val model = Build.MODEL
                    if (model.lowercase().startsWith(manufacturer.lowercase())) {
                        result.success(model.replaceFirstChar { it.uppercase() })
                    } else {
                        result.success("${manufacturer.replaceFirstChar { it.uppercase() }} $model")
                    }
                }
                "getOsVersion" -> {
                    result.success("Android ${Build.VERSION.RELEASE}")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}