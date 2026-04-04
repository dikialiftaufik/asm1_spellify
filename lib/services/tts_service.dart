import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  // Ubah inisialisasi menjadi fungsi asinkron agar sistem OS benar-benar menerapkan pengaturan bahasa Inggris sebelum berbicara.
  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> spellIncorrectWord(String word) async {
    String spelledWord = word.split('').join('-');
    await _flutterTts.speak("Incorrect. The correct spelling is, $spelledWord");
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
