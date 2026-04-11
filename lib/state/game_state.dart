import 'package:flutter/foundation.dart';
import '../models/word_model.dart';
import '../services/asset_service.dart';
import '../services/tts_service.dart';

class GameState extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  List<WordModel> _sessionWords = [];
  int _currentWordIndex = 0;
  int _lives = 3;
  int _score = 0;

  bool _isLoading = false;
  bool _isGameOver = false;
  bool _hasStarted = false;
  bool _isWaitingForNext = false;

  int get lives => _lives;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isGameOver => _isGameOver;
  bool get hasStarted => _hasStarted;
  bool get isWaitingForNext => _isWaitingForNext;
  int get currentWordNumber => _currentWordIndex + 1;
  int get totalWords => _sessionWords.length;

  WordModel? get currentWord {
    if (_sessionWords.isEmpty) return null;
    return _sessionWords[_currentWordIndex];
  }

  GameState();

  Future<void> startGame() async {
    _isLoading = true;
    notifyListeners();

    await _ttsService.init();
    _sessionWords = await AssetService.loadFullSession();

    _isLoading = false;
    _hasStarted = true;
    notifyListeners();

    if (_sessionWords.isNotEmpty) {
      await playCurrentWord();
    }
  }

  Future<void> playCurrentWord() async {
    if (currentWord != null) await _ttsService.speak(currentWord!.word);
  }

  Future<void> playDefinition() async {
    if (currentWord != null)
      await _ttsService.speak("The definition is: ${currentWord!.definition}");
  }

  Future<void> playContext() async {
    if (currentWord != null)
      await _ttsService.speak("Listen to the context: ${currentWord!.context}");
  }

  Future<bool> checkSpelling(String input) async {
    if (_isGameOver || currentWord == null || _isWaitingForNext) return false;

    String sanitizedInput = input.toLowerCase().trim();
    String correctWord = currentWord!.word.toLowerCase().trim();

    if (sanitizedInput == correctWord) {
      _calculateScore();

      if (_currentWordIndex < _sessionWords.length - 1) {
        _currentWordIndex++;
        notifyListeners();

        // PERBAIKAN: Menghapus keyword 'await' dan menggunakan Future.delayed
        // sebagai 'Fire-and-Forget'. Fungsi tidak akan tertahan di sini dan
        // akan langsung me-return 'true' ke UI seketika!
        Future.delayed(const Duration(milliseconds: 1000), () {
          playCurrentWord();
        });
      } else {
        _isGameOver = true;
        notifyListeners();
        _ttsService.speak(
          "Congratulations! You are the Spelling Bee Champion!",
        );
      }
      return true; // Eksekusi langsung ke sini untuk memicu kedip hijau UI
    } else {
      _lives--;

      if (_lives <= 0) {
        _isGameOver = true;
        notifyListeners();
        _ttsService.speak("Game Over. Thank you for playing.");
      } else {
        _isWaitingForNext = true;
        notifyListeners();

        // PERBAIKAN: Menghapus keyword 'await'.
        // Juri akan mengeja di background, sementara kode langsung turun
        // ke baris berikutnya untuk me-return 'false' ke UI seketika!
        _ttsService.spellIncorrectWord(currentWord!.word);
      }
      return false; // Eksekusi langsung ke sini untuk memicu kedip merah UI
    }
  }

  Future<void> advanceToNextWord() async {
    if (_isWaitingForNext) {
      _isWaitingForNext = false;

      // PERBAIKAN: Hentikan suara paksa jika pengguna menekan tombol
      // "Next Word" saat juri masih sibuk mengeja.
      await _ttsService.stop();

      if (_currentWordIndex < _sessionWords.length - 1) {
        _currentWordIndex++;
        notifyListeners();
        await playCurrentWord();
      }
    }
  }

  Future<void> restartGame() async {
    await _ttsService.stop(); // Pastikan tidak ada sisa suara sebelum restart
    _currentWordIndex = 0;
    _lives = 3;
    _score = 0;
    _isGameOver = false;
    _isWaitingForNext = false;

    await startGame();
  }

  void _calculateScore() {
    // Mode Demo (4 Kata)
    if (_currentWordIndex == 0) {
      _score += 100;
    } else if (_currentWordIndex == 1) {
      _score += 200;
    } else if (_currentWordIndex == 2) {
      _score += 300;
    } else {
      _score += 500;
    }
  }
}
