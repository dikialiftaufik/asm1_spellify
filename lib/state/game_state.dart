import 'package:flutter/foundation.dart';
import '../models/word_model.dart';
import '../services/asset_service.dart';
import '../services/tts_service.dart';

// GameState mewarisi ChangeNotifier agar UI bisa "mendengarkan" perubahan datanya
class GameState extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  // Variabel-variabel data (State)
  List<WordModel> _sessionWords = [];
  int _currentWordIndex = 0;
  int _lives = 3;
  int _score = 0;
  bool _isLoading = true;
  bool _isGameOver = false;

  // Getter (Akses baca-saja untuk UI)
  int get lives => _lives;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isGameOver => _isGameOver;
  int get currentWordNumber => _currentWordIndex + 1;
  int get totalWords => _sessionWords.length;

  WordModel? get currentWord {
    if (_sessionWords.isEmpty) return null;
    return _sessionWords[_currentWordIndex];
  }

  // Konstruktor akan otomatis memanggil proses inisialisasi saat objek dibuat
  GameState() {
    _initGame();
  }

  // Memuat data JSON dan memulai permainan
  Future<void> _initGame() async {
    _isLoading = true;
    notifyListeners();

    _sessionWords = await AssetService.loadFullSession();
    _isLoading = false;
    notifyListeners();

    // Membacakan kata pertama secara otomatis jika data berhasil dimuat
    if (_sessionWords.isNotEmpty) {
      await playCurrentWord();
    }
  }

  // Fungsi-fungsi Bantuan Juri (Audio)
  Future<void> playCurrentWord() async {
    if (currentWord != null) {
      await _ttsService.speak(currentWord!.word);
    }
  }

  Future<void> playDefinition() async {
    if (currentWord != null) {
      await _ttsService.speak("The definition is: ${currentWord!.definition}");
    }
  }

  Future<void> playContext() async {
    if (currentWord != null) {
      await _ttsService.speak("Listen to the context: ${currentWord!.context}");
    }
  }

  // Fungsi utama untuk memvalidasi tebakan user
  // Mengembalikan true jika benar, false jika salah, agar UI tahu kapan harus berkedip merah/hijau
  Future<bool> checkSpelling(String input) async {
    if (_isGameOver || currentWord == null) return false;

    // VALIDASI STRICT: Case-insensitive dan menghapus spasi awal/akhir
    String sanitizedInput = input.toLowerCase().trim();
    String correctWord = currentWord!.word.toLowerCase().trim();

    if (sanitizedInput == correctWord) {
      // JAWABAN BENAR
      _calculateScore();

      if (_currentWordIndex < _sessionWords.length - 1) {
        // Lanjut ke kata berikutnya
        _currentWordIndex++;
        notifyListeners();

        // Jeda sejenak agar user bisa melihat indikator hijau di layar
        await Future.delayed(const Duration(milliseconds: 1500));
        await playCurrentWord();
      } else {
        // Pemain berhasil menyelesaikan semua kata (Championship Word)
        _isGameOver = true;
        notifyListeners();
        await _ttsService.speak(
          "Congratulations! You are the Spelling Bee Champion!",
        );
      }
      return true;
    } else {
      // JAWABAN SALAH
      _lives--;
      notifyListeners();

      // Juri mengeja hurufnya satu per satu
      await _ttsService.spellIncorrectWord(currentWord!.word);

      if (_lives <= 0) {
        _isGameOver = true;
        notifyListeners();
        await _ttsService.speak("Game Over. Thank you for playing.");
      }
      return false;
    }
  }

  // Fungsi internal untuk menghitung bobot skor berdasarkan aturan indeks
  void _calculateScore() {
    if (_currentWordIndex < 10) {
      _score += 100; // Beginner (Kata 1-10)
    } else if (_currentWordIndex < 20) {
      _score += 200; // Intermediate (Kata 11-20)
    } else if (_currentWordIndex < 29) {
      _score += 300; // Advanced (Kata 21-29)
    } else {
      _score += 500; // Championship Word (Kata 30)
    }
  }
}
