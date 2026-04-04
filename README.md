# Spellify 🐝

_The Ultimate Spelling Bee Champion App_

## 📖 Deskripsi Aplikasi

**Spellify** adalah aplikasi permainan edukatif berbasis _mobile_ (ditenagai oleh Flutter) yang dirancang untuk menguji, mengasah, dan meningkatkan literasi ejaan (spelling) pengguna melalui simulasi nyata sebuah kompetisi _Spelling Bee_. Aplikasi ini bertindak layaknya seorang juri profesional—mendiktekan kata demi kata dengan presisi audio, di mana pemain bertugas mengidentifikasi dan mengetikkan ejaan secara akurat sebelum nyawa permainan mereka habis.

## 🎯 Latar Belakang

Pemahaman kosakata (_vocabulary_) dan ketajaman mengeja khususnya dalam Bahasa Inggris telah menjadi kompetensi dasar di era komunikasi berstandar global. Sayangnya, banyak instrumen pembelajaran seringkali dirasa monoton sehingga tidak memfasilitasi retensi kognitif yang baik. Di sisi lain, turnamen Spelling Bee secara masif berhasil membangun animo belajar progresif, namun kompetisi semacam ini tidak selalu mudah dijangkau bagi latihan mandiri setiap hari. Dibutuhkan medium interaktif yang sanggup mengadaptasi suasana gugup, fokus, dan gembira dari kompetisi tersebut ke dalam genggaman perangkat _smartphone_.

## 💡 Solusi

Spellify hadir sebagai pemecah masalah tersebut dengan menyediakan arena **digital Spelling Bee** yang adaptif. Memanfaatkan teknologi Text-to-Speech (TTS), aplikasi memicu sensitivitas intelektual di sisi pemrosesan suara (auditory). Ditunjang desain aplikasi (_User Interface_) yang ramah pengguna, gamifikasi interaktif, serta ketersediaan opsi bantuan (_Jury Assistance_), pembelajaran yang terkesan akademis dan kaku sukses diubah menjadi pengalaman menantang yang nagih _(addictive)_ namun tetap berbobot tinggi.

## ✨ Fitur Utama

Aplikasi Spellify mengusung standar rancangan interaksi yang kaya akan fitur, antara lain:

1. **Auditory Spelling Test:** Pengucapan kosakata otomatis dengan penekanan akurat oleh asisten suara. Pengguna juga difasilitasi tombol _play_ khusus untuk mendengar ulang audio jika merasa ragu.
2. **Jury Assistance Menu:** Aturan orisinal dari kejuaraan Spelling Bee telah disuntikkan. Saat pengguna menemui kata yang _tricky_ (menjebak), mereka berhak mengakses menu bantuan untuk meminta:
   - _May I have the definition?_ (Membacakan deskripsi artis/kamus dari kata tersebut).
   - _Can you use it in a sentence?_ (Membacakan kalimat konteks sehingga pemain dapat membedakan homofon).
3. **Dynamic Scoring System:** Penghitungan skor dengan model gradasi eksponensial. Semakin jauh pengguna berhasil menebak urutan kata berturut-turut, semakin besar ganjaran _multiplier_ skor yang diraih (Mulai dari 100, lalu naik menjadi 200, 300, hingga batas akhir 500 poin per kata).
4. **Health/Lives Mechanics:** Sistem tiga nyawa (3 _lives_). Kesalahan pengejaan akan mendapatkan penalti kehilangan nyawa, lalu sistem secara mandiri akan memberikan sesi umpan balik _(feedback)_ dengan mengejakan karakter per karakter alfabet dari jawaban yang benar demi menumbuhkan kemampuan pemahaman si pengguna.
5. **Real-time Feedback UI:** Impelementasi status visual yang instan—kilatan warna hijau untuk melambangkan repetisi yang akurat, serta kilatan merah dengan rintangan layar informatif untuk jawaban yang salah.
6. **Adaptive Game Flow:** Permainan dirajut sedemikian rupa mengaliri transisi mulus dari _Welcome Screen_ pembuka, menuju ranah pertempuran layar _Active Gameplay_, hingga pendaratan ke _Game Over Screen_ dengan tombol pengulangan tanpa perlu memuat ulang keseluruhan aplikasi _(No Dead-End Flow)_.

## 🛠️ Teknologi & Library yang Digunakan

Sistem front-end dan arsitektur Spellify diformulasikan memanfaatkan ekosistem pengembangan modern melalui **Flutter (Dart SDK)**:

- **`flutter` SDK:** Inti framework grafis lintas platform.
- **`flutter_tts` (^4.2.5):** Paket integrasi modul _Text-to-Speech (TTS)_ yang mengontrol sistem narasi suara pada OS perangkat (Android TTS atau iOS AVSpeechSynthesizer).

  **Daftar Implementasi API `flutter_tts` pada Aplikasi:**
  - `setLanguage("en-US")`: Mengalihkan pangkalan bahasa mutlak ke _US English_ untuk memastikan fonetik, aksen, dan cara baca sesuai standar Spelling Bee.
  - `setPitch(1.0)`: Mempertahankan frekuensi suara (_pitch_) agar selaras dan jernih layaknya juri manusia asli.
  - `setSpeechRate()`: Diimplementasikan secara dinamis (_Dynamic Engine_):
    - **Normal (0.45):** Diterapkan saat mendiktekan kosakata utuh, definisi, dan frasa kalimat.
    - **Lambat (0.25):** Dipicu sewaktu _user_ melakukan kesalahan (Trigger umpan balik). Bot otomatis melafalkan huruf per huruf (ejaan terpisah koma) secara perlahan.
  - `speak(String text)`: Fungsi injeksi leksikal untuk mengeksekusi instruksi verbal. Mulai dari perintah panjang (kalimat konteks) sampai penyebutan huruf tunggal (_A, P, P, L, E_).
  - `stop()`: Interupsi sinkronikal jika mesin dipaksa terhenti untuk membersihkan alur memori audio.

## ⚙️ Arsitektur Aplikasi & Pemanggilan Layanan

Kendati Spellify mengandalkan pangkalan data bank kata di dalam direktori internal _(offline local JSON asset)_ dan tidak menembak langsung _endpoint_ HTTP/REST eksternal, fondasinya dibangun beralaskan konsep _State Management_ modern dan _Service-based abstraction_ yang _scalable_ standar industri lunak:

1. **`GameState` Manager (State Management - ChangeNotifier):**
   Bertanggung jawab sebagai _Central Control Unit_. Semua modul evaluasi logika (_Scoring, Lives calculation, State lifecycle_) diamankan di dalam komponen ini. Hal ini memastikan UI (Screen Component) hanya bersifat sebagai pengamat (_listener_ melalui `ListenableBuilder`) sehingga tercapai _Separation of Concern_.
2. **`TtsService` (Native Interface Delegation):**
   _Wrapper_ atau abstraktor khusus kelas `TtsService` diinisiasi untuk mengamankan manajemen modul suara sistem. Menjadikan transisi audio yang tidak menabrak status game (seperti mengatur jeda _delay_, inisiasi sintesis _incorrect word_, hingga ucapan dekaratif ucapan selamat).
3. **`AssetService` (Data Parsing & Deserialization):**
   Mengakomodasi ekstraksi dan proses deserialisasi bank kata (_words list_) dari format mentah (seperti yang terdapat pada file `advanced.json` atau `intermediate.json`) masuk ke dalam format entitas terkendali `WordModel`.

## 📐 Struktur Direktori Proyek

Proyek ini mengadopsi standarisasi pembagian Layered Folder Architecture:

- `lib/models/`: Menempatkan cetak biru struktur objek (seperti `word_model.dart`) guna menstimulasi performa yang _Type-safe_.
- `lib/screens/`: Repositori grafikal pengguna, tempat peramuan tata letak _Widget_ utama.
- `lib/services/`: Mengurusi ranah logikal, fasilitator injeksi modul IO _(Input/Output)_, dan interaksi Native.
- `lib/state/`: Ruang reaktivitas status kondisi permainan terpusat.

## 🚀 Panduan Instalasi (Installation Guide)

Untuk melakukan uji coba pada lingkungan pengembangan lokal Anda, patuhi metodologi dasar berikut:

1. Ekstrak atau lakukan kloning dengan memastikan utilitas lingkungan _Flutter SDK_ pada gawai terminal Anda setidaknya telah ter-update (Kompatibilitas ^3.9.2).
2. Translasikan navigasi CLI ke dalam _root_ direktori proyek `asm1_spellify`.
3. Pasang semua dependensi terkait melalui peluncuran:
   ```bash
   flutter pub get
   ```
4. Aktifkan koneksi pada emulator (AVD/Simultor) kesayangan Anda, atau hubungkan fisik ponsel via mod _USB Debugging_.
5. Suntikkan peluncuran eksekusi _debug_ aplikasi dari konsol:
   ```bash
   flutter run
   ```

---
