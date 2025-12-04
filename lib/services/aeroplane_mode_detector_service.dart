import 'package:flutter/services.dart';

class AeroplaneModeDetectorService {
  
  static const EventChannel _eventChannel = EventChannel("airplane_mode_events");

  static Stream<bool> get aeroplaneModeStream{
    return _eventChannel.receiveBroadcastStream().map((event)=>event as bool);
  }

}