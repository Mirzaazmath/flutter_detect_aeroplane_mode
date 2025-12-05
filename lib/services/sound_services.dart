import 'package:flutter/services.dart';

class SoundPlayer {
  static const MethodChannel _channel = MethodChannel("play_warning_sound");

  static Future<void> play() async {
    await _channel.invokeMethod("play");
  }
}
