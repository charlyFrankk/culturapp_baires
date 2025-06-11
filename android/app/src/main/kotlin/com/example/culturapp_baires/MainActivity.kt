package com.unaj.culturapp_baires

import com.unaj.culturapp_baires.BuildConfig
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.unaj.culturapp_baires/apikeys"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getApiKey") {
                val keyName = call.argument<String>("key")
                val apiKey = when (keyName) {
                    "GOOGLE_GEMINI_API_KEY" -> BuildConfig.GOOGLE_GEMINI_API_KEY
                    "GOOGLE_SEARCH_API_KEY" -> BuildConfig.GOOGLE_SEARCH_API_KEY
                    "GOOGLE_SEARCH_CX" -> BuildConfig.GOOGLE_SEARCH_CX
                    "MONGODB_USER" -> BuildConfig.MONGODB_USER
                    "MONGODB_PWD" -> BuildConfig.MONGODB_PWD
                    "MONGODB_SERVER" -> BuildConfig.MONGODB_SERVER
                    "MONGODB_COLLECTION" -> BuildConfig.MONGODB_COLLECTION
                    "MONGODB_CLUSTER" -> BuildConfig.MONGODB_CLUSTER
                    else -> null
                }
                result.success(apiKey)
            } else {
                result.notImplemented()
            }
        }
    }
}