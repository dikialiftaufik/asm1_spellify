import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

// Layanan ini bertanggung jawab HANYA untuk mengambil data dari lokal (assets).
class AssetService {
  // Mengambil sejumlah kata acak (sample) dari file JSON tertentu.
  // fileName adalah nama file (contoh: 'beginner.json').
  // count adalah jumlah kata yang ingin diambil.
  static Future<List<WordModel>> getRandomWords(
    String fileName,
    int count,
  ) async {
    try {
      // 1. Membaca fail JSON dari folder assets sebagai String
      final String response = await rootBundle.loadString(
        'assets/data/$fileName',
      );

      // 2. Mengubah string JSON menjadi tipe List dinamis
      final List<dynamic> data = json.decode(response);

      // 3. Mengubah (map) setiap item JSON mentah menjadi objek WordModel
      List<WordModel> allWords = data
          .map((item) => WordModel.fromJson(item))
          .toList();

      // 4. Mengacak urutan daftar kata (Shuffle) agar permainan tidak repetitif
      allWords.shuffle();

      // 5. Mengambil sampel kata sesuai jumlah yang diminta (count).
      // Kita menggunakan .take() agar aplikasi tidak crash jika jumlah
      // kata di JSON ternyata kurang dari target count.
      return allWords.take(count).toList();
    } catch (e) {
      // Menangkap dan mencetak error jika fail tidak ditemukan atau formatnya salah
      print("Error loading $fileName: $e");
      return [];
    }
  }

  // Fungsi pembantu untuk memuat seluruh sesi permainan (Total 30 kata)
  // Sesuai aturan: 10 Beginner, 10 Intermediate, 9 Advanced, 1 Championship.
  static Future<List<WordModel>> loadFullSession() async {
    final List<WordModel> sessionWords = [];

    // Mengambil kata secara berurutan lalu menggabungkannya ke dalam satu sesi
    // DEMO MODE (diubah setelah selesai asesmen)
    sessionWords.addAll(await getRandomWords('beginner.json', 1));
    sessionWords.addAll(await getRandomWords('intermediate.json', 1));
    sessionWords.addAll(await getRandomWords('advanced.json', 1));
    sessionWords.addAll(await getRandomWords('championship.json', 1));

    return sessionWords;
  }
}
