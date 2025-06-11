import 'package:flutter/services.dart';

class ApiKeyProvider {
  static const MethodChannel _channel = MethodChannel("com.unaj.culturapp_baires/apikeys");

  static Future<String?> getApiKey(String keyName) async {
    try {
      final String? apiKey = await _channel.invokeMethod("getApiKey", {"key": keyName});
      return apiKey;
    } catch (e) {
      return null;
    }
  }
}
