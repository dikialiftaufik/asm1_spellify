import 'package:flutter/material.dart';
import 'screens/main_game_screen.dart';

void main() {
  // Memastikan binding Flutter sudah siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpellifyApp());
}

class SpellifyApp extends StatelessWidget {
  const SpellifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spellify',
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita "DEBUG" di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Layar pertama yang dimuat saat aplikasi dibuka
      home: const MainGameScreen(),
    );
  }
}
