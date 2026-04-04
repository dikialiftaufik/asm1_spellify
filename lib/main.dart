import 'package:flutter/material.dart';
import 'screens/main_game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpellifyApp());
}

class SpellifyApp extends StatelessWidget {
  const SpellifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spellify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Skema warna ungu tua/biru keunguan yang elegan
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF231F7B)),
        useMaterial3: true,
      ),
      home: const MainGameScreen(),
    );
  }
}
