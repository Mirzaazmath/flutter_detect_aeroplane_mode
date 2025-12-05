import 'package:flutter/services.dart';

class OpenSettingsService {
  static const MethodChannel _channel =
  MethodChannel("open_airplane_settings");

  static Future<void> openAirplaneSettings() async {
    await _channel.invokeMethod("open_airplane");
  }
}
