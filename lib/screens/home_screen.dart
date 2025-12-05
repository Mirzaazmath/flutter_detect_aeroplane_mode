import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_detect_aeroplane_mode/services/aeroplane_mode_detector_service.dart';

import '../services/sound_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<bool>? _streamSubscription;
  bool isBottomSheetOpen = false;

  @override
  void initState() {
    _streamSubscription = AeroplaneModeDetectorService.aeroplaneModeStream
        .listen((isOnMode) {
          if (isOnMode) {
            isBottomSheetOpen = true;
            showBottomSheetWarning();
          }else{
            if(isBottomSheetOpen){
              Navigator.of(context, rootNavigator: true).pop(); // Close dialog
              isBottomSheetOpen = false;
            }
          }
        });
    super.initState();
  }

  void showBottomSheetWarning()async {
    // 🔊 PLAY SOUND
    SoundPlayer.play();

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "⚠ Airplane Mode is ON",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Please turn OFF Airplane mode for proper app functionality.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Airplane Mode Detector App")));
  }
}
