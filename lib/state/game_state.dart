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

  // Menunggu pengguna menekan tombol "Lanjut" setelah jawaban salah
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

      // Feedback Audio saat jawaban benar
      await _ttsService.speak("That is correct!");

      if (_currentWordIndex < _sessionWords.length - 1) {
        _currentWordIndex++;
        notifyListeners();

        // Jeda untuk memberi waktu audio "That is correct" selesai berbicara
        await Future.delayed(const Duration(milliseconds: 2000));
        await playCurrentWord();
      } else {
        _isGameOver = true;
        notifyListeners();
        await _ttsService.speak(
          "Congratulations! You are the Spelling Bee Champion!",
        );
      }
      return true;
    } else {
      _lives--;

      if (_lives <= 0) {
        _isGameOver = true;
        notifyListeners();
        await _ttsService.speak("Game Over. Thank you for playing.");
      } else {
        // Jika masih ada nyawa, masuk ke state menunggu
        _isWaitingForNext = true;
        notifyListeners();
        await _ttsService.spellIncorrectWord(currentWord!.word);
      }
      return false;
    }
  }

  // Fungsi baru untuk dipanggil saat tombol "Next Word" ditekan
  Future<void> advanceToNextWord() async {
    if (_isWaitingForNext) {
      _isWaitingForNext = false;
      if (_currentWordIndex < _sessionWords.length - 1) {
        _currentWordIndex++;
        notifyListeners();
        await playCurrentWord();
      }
    }
  }

  void _calculateScore() {
    if (_currentWordIndex < 10) {
      _score += 100;
    } else if (_currentWordIndex < 20) {
      _score += 200;
    } else if (_currentWordIndex < 29) {
      _score += 300;
    } else {
      _score += 500;
    }
  }
}
