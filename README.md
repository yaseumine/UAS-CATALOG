# 🌾 Toko Tani Pierre - UTS Pemrograman Mobile Lanjutan

Aplikasi ini dikembangkan untuk memenuhi syarat **Ujian Tengah Semester (UTS)** mata kuliah Pemrograman Mobile Lanjutan. Project ini mengintegrasikan ekosistem **Flutter**, **Firebase**, dan **Backend Golang** dengan arsitektur yang terstruktur.

---

## 📺 Link Presentasi Video (WAJIB)

Silakan klik tautan di bawah ini untuk melihat demo aplikasi dan penjelasan arsitektur:

👉 **[Link Video YouTube Presentasi UTS - Klik di Sini](https://youtu.be/VtJiSEvb8hc)**

_Video mencakup: Penjelasan Arsitektur (Clean Architecture), Demo Register & Verify Email, Integrasi JWT, dan Alur Checkout._

---

## 👤 Profil Mahasiswa

- **Nama:** Aulia Yasmin Maharani
- **NIM:** 1123150146
- **Kelas:** TI SE P2 2023
- **Dosen Pengampu:** I Ketut Gunawan, M.Kom.

---

## 🚀 Fitur & Implementasi Teknis

### 1. Authentication & Security

- **Firebase Auth:** Digunakan untuk proses Register dan Login.
- **Email Verification:** Sistem mengunci akses masuk jika email belum diverifikasi (sesuai instruksi soal).
- **JWT Integration:** Token Firebase diverifikasi di Backend Golang untuk ditukar dengan JWT sebagai akses API Protected.

### 2. Management State & Architecture

- **State Management:** Menggunakan **Provider** dengan pola `ChangeNotifier` dan `notifyListeners()` untuk reaktivitas UI pada fitur Keranjang (Cart).
- **Clean Architecture:** Struktur folder dipisah menjadi `core` dan `features` (auth, catalog, cart) untuk skalabilitas kode.

### 3. Backend & Database

- **REST API:** Dikembangkan menggunakan Golang.
- **Database:** MySQL dengan **GORM** sebagai ORM.
- **Seeder:** Data produk (Benih, Pupuk, dsb) di-generate melalui script seeder Golang.

---

## 📂 Struktur Project (Flutter)

```text
lib/
├── core/
│   ├── constants/    # AppColors, AppTheme
│   └── routes/       # AppRouter
├── features/
│   ├── auth/         # Provider, Pages, Widgets (Header, TextField)
│   ├── catalog/      # Dashboard, Product Models
│   └── cart/         # CartProvider, CartItem Model, Checkout Page
└── main.dart
```
