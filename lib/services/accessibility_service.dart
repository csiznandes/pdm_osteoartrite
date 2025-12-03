import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import '../utils/user_session.dart';

class AccessibilityService with ChangeNotifier {
  bool _fontPref = false;
  bool _contrastPref = false;
  bool _voiceReadPref = false;
  
  final FlutterTts flutterTts = FlutterTts(); //Instância do motor TTS.

  final ApiService _apiService = ApiService();  //Instância do serviço de API.

  bool get fontPref => _fontPref;
  bool get contrastPref => _contrastPref;
  bool get voiceReadPref => _voiceReadPref;

  AccessibilityService() {
    _initTts(); //Inicializa o motor TTS no construtor.
  }
  //Configurações da leitura por voz
  void _initTts() {
    flutterTts.setLanguage("pt-BR");
    flutterTts.setSpeechRate(0.60);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);
  }
  //Define todas as preferências de uma vez.
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
  //Toggles individuais para cada preferência.
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
  //Função principal para iniciar a leitura de um texto.
  Future<void> speak(String text) async {
    if (_voiceReadPref) {
      await flutterTts.stop();
      await flutterTts.speak(text);
    }
  }
  //Função para interromper imediatamente qualquer leitura em andamento.
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }
  //Método que busca as configurações de acessibilidade do usuário no backend e aplica-as ao estado do serviço.
  Future<void> loadPreferencesFromApi() async {
    if (UserSession.userId == null) {
      return;
    }

    try {
      final data = await _apiService.getUser(UserSession.userId!);
      final access = data['accessibility'] as Map<String, dynamic>? ?? {};

      setPreferences(
        font: access['font'] ?? false,
        contrast: access['contrast'] ?? false,
        voiceRead: access['voice_read'] ?? false,
      );

    } catch (e) {
      print('Erro ao carregar preferências de acessibilidade: $e');
    }
  }
}
