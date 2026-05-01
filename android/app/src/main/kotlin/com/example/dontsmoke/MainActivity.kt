package com.dontsmoke.kz

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val WIDGET_CHANNEL = "com.dontsmoke.kz/widget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveWidgetData" -> {
                        DontSmokeWidgetProvider.updateAllWidgets(this)
                        DontSmokeWidgetProvider.scheduleWidgetRefresh(this)
                        result.success(null)
                    }
                    "clearWidgetData" -> {
                        DontSmokeWidgetProvider.updateAllWidgets(this)
                        DontSmokeWidgetProvider.cancelWidgetRefresh(this)
                        result.success(null)
                    }
                    "refreshWidget" -> {
                        DontSmokeWidgetProvider.updateAllWidgets(this)
                        DontSmokeWidgetProvider.scheduleWidgetRefresh(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
