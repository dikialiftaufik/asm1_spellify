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

  // Getters untuk akses state dari UI
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

  Future<void> startGame() async {
    _isLoading = true;
    notifyListeners();

    await _ttsService.init();
    _sessionWords = await AssetService.loadFullSession();

    _isLoading = false;
    _hasStarted = true;
    notifyListeners();

    if (_sessionWords.isNotEmpty) await playCurrentWord();
  }

  Future<void> playCurrentWord() async {
    if (currentWord != null) await _ttsService.speak(currentWord!.word);
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

  Future<bool> checkSpelling(String input) async {
    if (_isGameOver || currentWord == null || _isWaitingForNext) return false;

    String sanitizedInput = input.toLowerCase().trim();
    String correctWord = currentWord!.word.toLowerCase().trim();

    if (sanitizedInput == correctWord) {
      _calculateScore();

      if (_currentWordIndex < _sessionWords.length - 1) {
        _currentWordIndex++;
        notifyListeners();
        // Fire-and-Forget: langsung return true tanpa menunggu audio selesai
        Future.delayed(const Duration(milliseconds: 1000), () => playCurrentWord());
      } else {
        _isGameOver = true;
        notifyListeners();
        _ttsService.speak("Congratulations! You are the Spelling Bee Champion!");
      }
      return true;
    } else {
      _lives--;

      if (_lives <= 0) {
        _isGameOver = true;
        notifyListeners();
        _ttsService.speak("Game Over. Thank you for playing.");
      } else {
        _isWaitingForNext = true;
        notifyListeners();
        // Fire-and-Forget: juri mengeja di background, UI langsung responsif
        _ttsService.spellIncorrectWord(currentWord!.word);
      }
      return false;
    }
  }

  // Pemain salah menjawab → beri kesempatan coba lagi kata yang SAMA
  Future<void> retryCurrentWord() async {
    if (!_isWaitingForNext) return;
    _isWaitingForNext = false;

    // Hentikan suara jika juri masih mengeja
    await _ttsService.stop();

    // Tidak pindah kata — tetap di kata yang sama agar pemain bisa coba lagi
    notifyListeners();
    await playCurrentWord();
  }

  Future<void> restartGame() async {
    await _ttsService.stop();
    _currentWordIndex = 0;
    _lives = 3;
    _score = 0;
    _isGameOver = false;
    _isWaitingForNext = false;
    await startGame();
  }

  // Skor berdasarkan tingkat kesulitan kata (Demo Mode: 4 kata)
  void _calculateScore() {
    const scores = [100, 200, 300, 500];
    _score += scores[_currentWordIndex.clamp(0, scores.length - 1)];
  }
}
