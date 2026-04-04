import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("en-US");
    // Kecepatan normal
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    // Memastikan kecepatan kembali normal untuk kalimat biasa
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.speak(text);
  }

  Future<void> spellIncorrectWord(String word) async {
    // Menurunkan kecepatan drastis agar ejaan terdengar perlahan
    await _flutterTts.setSpeechRate(0.25);

    // Memecah kata dengan koma dan spasi untuk memberi jeda antar huruf
    String spelledWord = word.split('').join(', ');

    await _flutterTts.speak("Incorrect. The correct spelling is, $spelledWord");
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
