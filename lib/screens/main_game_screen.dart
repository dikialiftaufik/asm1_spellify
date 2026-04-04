import 'package:flutter/material.dart';
import '../state/game_state.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  // Menginisialisasi State Management (Otak Permainan)
  final GameState _gameState = GameState();

  // Controller untuk membaca inputan dari TextField
  final TextEditingController _textController = TextEditingController();

  // FocusNode digunakan agar kita bisa menahan keyboard tetap terbuka jika diperlukan
  final FocusNode _focusNode = FocusNode();

  // Variabel untuk mengontrol warna kedipan layar (transparan secara default)
  Color _flashColor = Colors.transparent;

  @override
  void dispose() {
    // Selalu biasakan membersihkan controller di metode dispose agar tidak terjadi memory leak
    _textController.dispose();
    _focusNode.dispose();
    _gameState.dispose();
    super.dispose();
  }

  // Fungsi untuk memproses tebakan user
  void _submitAnswer() async {
    final String input = _textController.text;
    if (input.isEmpty) return;

    // Kosongkan TextField setelah disubmit
    _textController.clear();

    // Panggil logika dari GameState dan tunggu hasilnya (true/false)
    bool isCorrect = await _gameState.checkSpelling(input);

    // Memicu animasi kedip layar
    _triggerFlash(
      isCorrect ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
    );
  }

  // Fungsi untuk membuat layar berkedip sekilas
  void _triggerFlash(Color color) async {
    setState(() {
      _flashColor = color;
    });

    // Tahan warna selama 400 milidetik
    await Future.delayed(const Duration(milliseconds: 400));

    // Kembalikan ke warna transparan
    if (mounted) {
      setState(() {
        _flashColor = Colors.transparent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spellify Championship'),
        centerTitle: true,
        elevation: 0,
      ),
      // Stack digunakan agar kita bisa menumpuk warna kedipan (Overlay) di atas UI utama
      body: Stack(
        children: [
          // ListenableBuilder akan menggambar ulang UI HANYA KETIKA _gameState memanggil notifyListeners()
          ListenableBuilder(
            listenable: _gameState,
            builder: (context, child) {
              if (_gameState.isLoading) {
                return const Center(child: CircularProgressIndicator());
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

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Status (Lives & Score & Word Number)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Word ${_gameState.currentWordNumber} / ${_gameState.totalWords}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Score: ${_gameState.score}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < _gameState.lives
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Tombol-tombol Bantuan Juri
                    // Menggunakan bahasa Inggris sesuai aturan
                    ElevatedButton.icon(
                      onPressed: () => _gameState.playCurrentWord(),
                      icon: const Icon(Icons.volume_up, size: 32),
                      label: const Text(
                        'Hear Again',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _gameState.playDefinition(),
                      icon: const Icon(Icons.book),
                      label: const Text('May I have the definition?'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _gameState.playContext(),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Can you use it in a context?'),
                    ),

                    const Spacer(),

                    // TextField Super Ketat (Blind Typing & No Autocorrect)
                    TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      // MEMATIKAN FITUR PINTAR KEYBOARD (Strict Rule)
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitAnswer(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 2.0),
                      decoration: InputDecoration(
                        hintText: 'Type your spelling here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Submit
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),

          // Lapisan Overlay untuk Animasi Kedip Adjudikasi
          // IgnorePointer memastikan sentuhan jari tetap diteruskan ke UI di bawahnya
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
}
