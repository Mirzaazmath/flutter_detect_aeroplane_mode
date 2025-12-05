package com.example.flutter_detect_aeroplane_mode

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaPlayer
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val AIRPLANE_EVENT_CHANNEL = "airplane_mode_events"
    private val SOUND_CHANNEL = "play_warning_sound"
    private val OPEN_SETTINGS_CHANNEL = "open_airplane_settings"

    private var eventSink: EventChannel.EventSink? = null
    private var player: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ========== EVENT CHANNEL (Airplane Mode Changes) ==========
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AIRPLANE_EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerAirplaneReceiver()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        // ========== METHOD CHANNEL (Play Warning Sound) ==========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SOUND_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "play") {
                playSound()
                result.success(null)
            }
        }

        // ========== METHOD CHANNEL (Open Airplane Settings) ==========
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            OPEN_SETTINGS_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "open_airplane") {
                openAirplaneSettings()
                result.success(null)
            }
        }
    }

    // ------------------ DETECT AIRPLANE MODE ------------------
    private fun registerAirplaneReceiver() {
        val filter = IntentFilter(Intent.ACTION_AIRPLANE_MODE_CHANGED)
        registerReceiver(object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val isOn = Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.AIRPLANE_MODE_ON,
                    0
                ) == 1
                eventSink?.success(isOn)
            }
        }, filter)
    }


    // ------------------ PLAY WARNING SOUND ------------------
    private fun playSound() {
        // If already created, release old one to avoid memory leaks
        player?.release()
        player = null

        player = MediaPlayer.create(this, R.raw.warning)
        player?.setOnCompletionListener {
            it.release()   // release when done
            player = null  // prevent memory leaks
        }

        player?.start()
    }



    // ------------------ OPEN AIRPLANE SETTINGS ------------------
    private fun openAirplaneSettings() {
        val intent = Intent(Settings.ACTION_AIRPLANE_MODE_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}
