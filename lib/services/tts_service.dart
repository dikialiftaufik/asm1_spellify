import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  // [API 1] Instansiasi objek utama FlutterTts
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // [API 2] Mengunci bahasa dan aksen ke English-US
    await _flutterTts.setLanguage("en-US");

    // [API 3] Mengatur kecepatan berbicara normal
    await _flutterTts.setSpeechRate(0.45);

    // [API 4] Mengatur tinggi nada suara (pitch) agar natural
    await _flutterTts.setPitch(1.0);

    // [API 5] Memaksa fungsi speak() agar await-nya benar-benar sinkron dan menunggu hingga audio selesai diputar.
    await _flutterTts.awaitSpeakCompletion(true);

    // [API 6] Callback saat mesin OS pertama kali mulai mengeluarkan suara.
    // Berguna jika ke depannya Anda ingin menyinkronkan animasi UI.
    _flutterTts.setStartHandler(() {
      print("System Log: Audio TTS Started");
    });

    // [API 7] Callback saat mesin OS berhasil menyelesaikan seluruh kalimat.
    // Menandakan siklus audio berjalan sempurna tanpa interupsi.
    _flutterTts.setCompletionHandler(() {
      print("System Log: Audio TTS Completed normally");
    });

    // [API 8] Callback keamanan jika suara dipotong paksa
    // (misal: ada telepon masuk atau aplikasi ditutup tiba-tiba).
    // Mencegah aplikasi mengalami deadlock / freeze.
    _flutterTts.setCancelHandler(() {
      print("System Warning: Audio TTS Cancelled or Interrupted");
    });

    _isInitialized = true;
  }

  // [API 9] Fungsi eksekusi utama untuk membaca teks
  Future<void> speak(String text) async {
    // Memastikan kecepatan selalu kembali normal untuk teks kalimat
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.speak(text);
  }

  Future<void> spellIncorrectWord(String word) async {
    // Menurunkan kecepatan drastis agar ejaan terdengar perlahan
    await _flutterTts.setSpeechRate(0.25);

    // Memecah kata dengan koma untuk memberi jeda antar huruf
    String spelledWord = word.split('').join(', ');

    await _flutterTts.speak("Incorrect. The correct spelling is, $spelledWord");
  }

  // [API 10] Fungsi untuk menghentikan audio secara paksa
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
