import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccessibilityService with ChangeNotifier {
  bool _fontPref = false;
  bool _contrastPref = false;
  bool _voiceReadPref = false;
  
  final FlutterTts flutterTts = FlutterTts();

  bool get fontPref => _fontPref;
  bool get contrastPref => _contrastPref;
  bool get voiceReadPref => _voiceReadPref;

  AccessibilityService() {
    _initTts();
  }

  void _initTts() {
  }

  void setPreferences({
    required bool font,
    required bool contrast,
    required bool voiceRead,
  }) {
    _fontPref = font;
    _contrastPref = contrast;
    _voiceReadPref = voiceRead;
    notifyListeners();
  }

  void toggleFontPref(bool value) {
    _fontPref = value;
    notifyListeners();
  }

  void toggleContrastPref(bool value) {
    _contrastPref = value;
    notifyListeners();
  }

  void toggleVoiceReadPref(bool value) {
    _voiceReadPref = value;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (_voiceReadPref) {
      await flutterTts.speak(text);
    }
  }
  
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }
  
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}