import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

// Layanan untuk mengambil data kata dari file JSON lokal (assets).
class AssetService {
  // Mengambil sejumlah kata acak dari file JSON tertentu.
  static Future<List<WordModel>> getRandomWords(String fileName, int count) async {
    try {
      // Membaca file JSON dari folder assets
      final String response = await rootBundle.loadString('assets/data/$fileName');

      // Decode JSON → List → Map ke WordModel
      List<WordModel> allWords = (json.decode(response) as List)
          .map((item) => WordModel.fromJson(item))
          .toList();

      // Acak urutan lalu ambil sejumlah 'count' kata
      allWords.shuffle();
      return allWords.take(count).toList();
    } catch (e) {
      print("Error loading $fileName: $e");
      return [];
    }
  }

  // Memuat satu sesi permainan lengkap (Total 4 kata - DEMO MODE).
  // Komposisi: 1 Beginner, 1 Intermediate, 1 Advanced, 1 Championship.
  static Future<List<WordModel>> loadFullSession() async {
    final List<WordModel> sessionWords = [];

    sessionWords.addAll(await getRandomWords('beginner.json', 1));
    sessionWords.addAll(await getRandomWords('intermediate.json', 1));
    sessionWords.addAll(await getRandomWords('advanced.json', 1));
    sessionWords.addAll(await getRandomWords('championship.json', 1));

    return sessionWords;
  }
}
