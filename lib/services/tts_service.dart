import 'package:flutter_tts/flutter_tts.dart';

// Layanan untuk mengontrol mesin Text-to-Speech (Audio)
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    // Konfigurasi dasar saat layanan pertama kali dibuat
    _flutterTts.setLanguage("en-US"); // Wajib bahasa Inggris untuk Spelling Bee
    _flutterTts.setSpeechRate(0.45); // Kecepatan pelafalan normal
    _flutterTts.setPitch(1.0);
  }

  // Fungsi untuk mengucapkan teks biasa
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Fungsi khusus adjudikasi saat jawaban salah
  // Memecah kata menjadi huruf demi huruf sesuai aturan permainan
  Future<void> spellIncorrectWord(String word) async {
    // memaksa TTS untuk mengeja hurufnya, bukan membacanya sebagai kata, contoh: 'apple' menjadi 'a-p-p-l-e'
    String spelledWord = word.split('').join('-');

    await _flutterTts.speak("Incorrect. The correct spelling is, $spelledWord");
  }

  // (Opsional) Fungsi untuk menghentikan audio jika diperlukan
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
