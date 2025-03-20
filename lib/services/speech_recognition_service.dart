import 'package:flutter/services.dart';

class SpeechRecognitionService {
  static const platform =
      MethodChannel('com.example.mamaapp/speech_recognition');
  static const EventChannel _eventChannel =
      EventChannel('com.example.mamaapp/speech_recognition_events');

  Future<bool> initialize() async {
    try {
      final bool result = await platform.invokeMethod('initialize');
      return result;
    } on PlatformException catch (e) {
      print('Error initializing speech recognition: ${e.message}');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    try {
      await platform.invokeMethod('startListening');
      _eventChannel.receiveBroadcastStream().listen((dynamic result) {
        if (result is String) {
          onResult(result);
        }
      });
    } on PlatformException catch (e) {
      print('Error starting speech recognition: ${e.message}');
    }
  }

  Future<void> stopListening() async {
    try {
      await platform.invokeMethod('stopListening');
    } on PlatformException catch (e) {
      print('Error stopping speech recognition: ${e.message}');
    }
  }
}
