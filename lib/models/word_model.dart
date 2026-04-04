// Kelas ini merepresentasikan struktur data untuk setiap kata dalam permainan.
// Kita menggunakan model ini agar data JSON yang mentah bisa diubah menjadi Objek Dart yang aman dan mudah dikelola (Type-Safe).
class WordModel {
  final String word;
  final String definition;
  final String context;

  WordModel({
    required this.word,
    required this.definition,
    required this.context,
  });

  /// Factory constructor untuk mengonversi data JSON (tipe Map) menjadi objek WordModel.
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      context: json['context'] ?? '',
    );
  }
}
