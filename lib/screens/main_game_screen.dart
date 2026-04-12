import 'package:flutter/material.dart';
import '../state/game_state.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  final GameState _gameState = GameState();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Color _flashColor = Colors.transparent;

  final Color _primaryColor = const Color(0xFF231F7B);

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _gameState.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    final String input = _textController.text;
    if (input.isEmpty) return;

    _focusNode.unfocus();
    bool isCorrect = await _gameState.checkSpelling(input);
    _textController.clear();
    _triggerFlash(
      isCorrect ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
    );
  }

  void _triggerFlash(Color color) async {
    setState(() => _flashColor = color);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _flashColor = Colors.transparent);
  }

  Widget _buildLivesIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 32,
          height: 6,
          decoration: BoxDecoration(
            color: index < _gameState.lives ? _primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // Helper: Membuat item ListTile untuk menu Jury Assistance
  Widget _buildJuryTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _primaryColor.withOpacity(0.1),
        child: Icon(icon, color: _primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showJuryAssistanceMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Jury Assistance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildJuryTile(Icons.menu_book_rounded, 'May I have the definition?', () {
                  Navigator.pop(context);
                  _gameState.playDefinition();
                }),
                _buildJuryTile(Icons.chat_bubble_rounded, 'Can you use it in a sentence?', () {
                  Navigator.pop(context);
                  _gameState.playContext();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper: Membuat tombol utama yang dipakai di banyak tempat
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Icon(icon, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Spellify',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: _gameState,
            builder: (context, child) {
              if (_gameState.isLoading) {
                return Center(child: CircularProgressIndicator(color: _primaryColor));
              }

              // --- WELCOME SCREEN ---
              if (!_gameState.hasStarted) return _buildWelcomeScreen();

              // --- GAME OVER SCREEN ---
              if (_gameState.isGameOver) return _buildGameOverScreen();

              // --- ACTIVE GAMEPLAY SCREEN ---
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Status Bar (Word count & Score)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Word ${_gameState.currentWordNumber} of ${_gameState.totalWords}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                ),
                                Text(
                                  'Score: ${_gameState.score}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildLivesIndicator(),
                          const SizedBox(height: 60),

                          // Tombol speaker (play word)
                          GestureDetector(
                            onTap: () => _gameState.playCurrentWord(),
                            child: Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primaryColor.withOpacity(0.05),
                                border: Border.all(color: _primaryColor.withOpacity(0.2), width: 2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryColor.withOpacity(0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.volume_up_rounded, size: 40, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Tap to hear the word',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 48),

                          // Tombol Jury Assistance
                          ActionChip(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            avatar: Icon(Icons.help_outline_rounded, size: 20, color: _primaryColor),
                            label: const Text('Jury Assistance', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: _showJuryAssistanceMenu,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Input Area
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(
                      left: 24, right: 24, top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).viewInsets.bottom + 16
                          : MediaQuery.of(context).padding.bottom + 24,
                    ),
                    child: _gameState.isWaitingForNext
                        ? _buildIncorrectState()
                        : _buildInputState(),
                  ),
                ],
              );
            },
          ),
          // Flash overlay (hijau/merah) saat jawab benar/salah
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _flashColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitAnswer(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, letterSpacing: 4.0, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Type here...',
            hintStyle: TextStyle(letterSpacing: 0, color: Colors.grey.shade300, fontSize: 18),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(
          label: 'Submit Spelling',
          icon: Icons.check_rounded,
          onPressed: _submitAnswer,
        ),
      ],
    );
  }

  Widget _buildIncorrectState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 32),
              const SizedBox(height: 8),
              Text(
                'Incorrect Spelling',
                style: TextStyle(color: Colors.red.shade700, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(
          label: 'Next Word',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => _gameState.advanceToNextWord(),
          backgroundColor: Colors.black87,
        ),
      ],
    );
  }

  // --- KOMPONEN WELCOME SCREEN ---
  Widget _buildWelcomeScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Logo dengan tile dekoratif
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.mic_rounded, size: 60, color: Colors.white),
                ),
                Positioned(top: 10, right: 0, child: _buildDecorativeTile("S")),
                Positioned(bottom: 10, left: 0, child: _buildDecorativeTile("B")),
              ],
            ),

            // Judul dan deskripsi
            const Column(
              children: [
                Text(
                  'Welcome to\nSpellify',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                Text(
                  'Test your spelling skills and\nbecome the ultimate champion!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),

            // Info bar: Listen → Spell → Win
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(Icons.headset_mic_rounded, "LISTEN"),
                  _buildInfoItem(Icons.keyboard_rounded, "SPELL"),
                  _buildInfoItem(Icons.emoji_events_rounded, "WIN"),
                ],
              ),
            ),

            // Tombol Start Game
            _buildPrimaryButton(
              label: 'Start Game',
              icon: Icons.play_arrow_rounded,
              onPressed: () => _gameState.startGame(),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN GAME OVER SCREEN ---
  Widget _buildGameOverScreen() {
    bool isVictory = _gameState.lives > 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVictory ? Icons.emoji_events_rounded : Icons.heart_broken,
              size: 100,
              color: isVictory ? const Color(0xFFFFD54F) : Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              isVictory ? 'Champion!' : 'Game Over',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isVictory ? _primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: ${_gameState.score}',
              style: TextStyle(fontSize: 20, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 48),
            _buildPrimaryButton(
              label: 'Play Again',
              icon: Icons.replay_rounded,
              onPressed: () => _gameState.restartGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeTile(String letter) {
    return Container(
      width: 40, height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.black87),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.black54),
        ),
      ],
    );
  }
}
