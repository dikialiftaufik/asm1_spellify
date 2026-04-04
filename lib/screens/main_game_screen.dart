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

    _focusNode.unfocus(); // Turunkan keyboard setelah submit
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

  // Widget khusus untuk merender nyawa berbentuk kapsul elegan
  Widget _buildLivesIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: index < _gameState.lives
                ? Colors.blueAccent
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
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
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.2),
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
                return const Center(child: CircularProgressIndicator());
              }

              // Layar Welcome Screen sebelum game dimulai
              if (!_gameState.hasStarted) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 48.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Lingkaran dengan dekorasi ubin B dan S
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFF231F7B,
                                ), // Warna ungu tua sesuai referensi
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mic,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                            // Ubin dekoratif
                            Positioned(
                              top: 20,
                              right: 0,
                              child: _buildDecorativeTile("S"),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 0,
                              child: _buildDecorativeTile("B"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        const Text(
                          'Welcome to Spellify',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Test your spelling skills and become the ultimate champion!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 60),

                        // Bagian Informasi Visual: LISTEN, SPELL, WIN
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem(
                                Icons.headset_mic_rounded,
                                "LISTEN",
                              ),
                              _buildInfoItem(Icons.keyboard_rounded, "SPELL"),
                              _buildInfoItem(Icons.emoji_events_rounded, "WIN"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Tombol Start Game dengan ikon panah
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => _gameState.startGame(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF231F7B,
                              ), // Warna ungu tua
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start Game',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_gameState.isGameOver) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Final Score: ${_gameState.score}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                );
              }

              // Arsitektur layout yang memisahkan konten atas dan input bawah (anti-overflow keyboard)
              return Column(
                children: [
                  // AREA ATAS (Dapat di-scroll jika layar kecil)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Word ${_gameState.currentWordNumber}/${_gameState.totalWords}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                'Score: ${_gameState.score}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLivesIndicator(),
                          const SizedBox(height: 80),

                          // Tombol putar ulang suara utama
                          Center(
                            child: InkWell(
                              onTap: () => _gameState.playCurrentWord(),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volume_up_rounded,
                                  size: 48,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'Tap to hear the word',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 48),

                          ActionChip(
                            avatar: const Icon(Icons.help_outline, size: 18),
                            label: const Text('Jury Assistance'),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Jury Assistance',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.book,
                                              color: Colors.blueAccent,
                                            ),
                                            title: const Text(
                                              'May I have the definition?',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _gameState.playDefinition();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.blueAccent,
                                            ),
                                            title: const Text(
                                              'Can you use it in a sentence?',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _gameState.playContext();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // AREA BAWAH (Sticky / Menempel di atas keyboard)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    // viewInsets.bottom mendeteksi tinggi keyboard secara otomatis
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).viewInsets.bottom + 16
                          : 32, // Padding normal jika keyboard ditutup
                    ),
                    child: _gameState.isWaitingForNext
                        // TAMPILAN JIKA SALAH (Menunggu pengguna lanjut)
                        ? Column(
                            children: [
                              const Text(
                                'Incorrect Spelling',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _gameState.advanceToNextWord(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Next Word',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        // TAMPILAN NORMAL (Input TextField)
                        : Column(
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
                                style: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type here...',
                                  hintStyle: TextStyle(
                                    letterSpacing: 0,
                                    color: Colors.grey.shade400,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.blueAccent,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _submitAnswer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
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

  // Widget pembantu untuk membangun ubin dekoratif
  Widget _buildDecorativeTile(String letter) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F), // Warna kuning sesuai referensi
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Widget pembantu untuk membangun item informasi visual (Listen, Spell, Win)
  Widget _buildInfoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.black54),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
