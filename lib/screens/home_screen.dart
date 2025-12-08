import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_detect_aeroplane_mode/services/aeroplane_mode_detector_service.dart';
import 'package:flutter_detect_aeroplane_mode/services/open_setting_services.dart';

import '../services/sound_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<bool>? _streamSubscription;
  bool isBottomSheetOpen = false;
  BuildContext? _bottomSheetContext;

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
    if (_bottomSheetContext != null) return; // already open

    //  PLAY SOUND
    SoundPlayer.play();

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) {
        _bottomSheetContext = context;
        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 200,
            child:  Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "⚠ Airplane Mode is ON",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Please turn OFF Airplane mode for proper app functionality.",
                  textAlign: TextAlign.center,
                ),
                GestureDetector(
                  onTap: (){
                    OpenSettingsService.openAirplaneSettings();
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text("Open Settings",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => _bottomSheetContext = null);;
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
