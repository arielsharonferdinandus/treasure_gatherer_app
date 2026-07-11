# Treasure Gatherer App

> Tugas Ujian Akhir Semester (UAS) — Mata Kuliah Mobile Computing
> Nama: Ariel Sharon Ferdinandus — NIM: 24130500007

Aplikasi mobile marketplace barang bekas ("harta karun") yang dikembangkan menggunakan Flutter, melanjutkan desain UI/UX dari UTS. Konsep aplikasi: pengguna dapat menjual dan membeli barang bekas, dengan sistem rating bintang otomatis yang menurun setiap kali barang terdeteksi dijual kembali oleh pembeli sebelumnya melalui aplikasi — barang dengan rating rendah otomatis dikategorikan ke dalam **"For Disassemble"**, ditujukan untuk engineer yang mencari komponen aktif untuk dibongkar.

## 🔗 Tautan Penting

- **Desain Figma (Public):** https://www.figma.com/design/gJwOnh2ps3oXtUV8AVgIlN/Mobile-Design?node-id=221-1864&t=3aGtP82ANGyWBgWs-1
- **Repository GitHub:** https://github.com/arielsharonferdinandus/treasure_gatherer_app

## 📱 Fitur Utama

1. **Onboarding & Autentikasi**
   - Landing page (onboarding carousel, ditampilkan sekali)
   - Login & Register dengan validasi input (format email, kekuatan password, dsb.)
2. **Halaman Utama (Home)**
   - Menampilkan daftar barang yang diambil langsung dari REST API (MockAPI)
   - Kategori otomatis: barang layak pakai vs. barang "For Disassemble"
   - Pull-to-refresh dan retry saat gagal memuat data
3. **Detail Barang (Product Page)**
   - Menampilkan data lengkap barang: foto, harga, deskripsi, kondisi/defect, rating bintang
   - Tombol **Beli Sekarang** dengan simulasi proses pembelian (countdown 5 detik) dan **Tambah ke Keranjang**
   - Tombol **Edit** untuk memperbarui data barang
4. **Jual Barang (Sell/Register)**
   - Form pendaftaran barang baru lengkap dengan foto wajib (kamera/galeri)
   - **Deteksi otomatis riwayat pembelian**: jika nama barang yang didaftarkan cocok dengan barang yang pernah dibeli pengguna melalui aplikasi, sistem otomatis menandainya sebagai barang re-sell dan meminta info durasi pemakaian — rating bintang awal akan dikurangi sesuai aturan. Barang benar-benar baru otomatis mendapat rating 5 bintang.
5. **Notifikasi Pembelian**
   - Setiap pembelian berhasil disimulasikan akan memicu **local notification** di perangkat.

## 🏗️ Software Architecture

Project ini menerapkan **MVC (Model-View-Controller)**, dengan Provider berperan sebagai lapisan Controller:

```
lib/
├── main.dart                     # Entry point, setup MultiProvider
├── core/
│   ├── shared_widgets/           # Widget reusable (mis. ItemImage)
│   └── utils/                    # Helper (mis. ImagePickerHelper)
├── data/
│   ├── models/                   # MODEL — Item, UserModel
│   └── services/                 # Akses data — AuthService, ItemService, NotificationService
├── providers/                    # CONTROLLER — AuthProvider, ItemProvider (State Management)
└── features/                     # VIEW — UI murni, tidak ada business logic
    ├── landing/
    ├── auth/                     # login_page.dart, register_page.dart
    ├── home/                     # home_page.dart
    └── product/                  # product_page.dart, register_page.dart, edit_page.dart
```

**Separation of Concerns:** Views hanya memanggil `context.watch/read<Provider>()` untuk membaca state dan memicu aksi — tidak ada logika bisnis atau akses `SharedPreferences`/HTTP langsung di dalam widget.

## ⚙️ State Management

Menggunakan **Provider** (`ChangeNotifier`) melalui dua provider utama:

- **`AuthProvider`** — status login, sesi pengguna, dan riwayat pembelian (untuk deteksi resell)
- **`ItemProvider`** — daftar barang, status loading/error, serta operasi create/update/delete barang

Kedua provider didaftarkan secara global lewat `MultiProvider` di `main.dart`, sehingga seluruh halaman dapat bereaksi otomatis terhadap perubahan data tanpa `setState` manual.

## 🌐 Integrasi REST API

Menggunakan **MockAPI** (`https://[project-id].mockapi.io/api/items`) sebagai backend untuk fitur utama daftar barang:

- `GET /items` — mengambil daftar barang (ditampilkan di Home)
- `POST /items` — mendaftarkan barang baru (fitur Jual Barang)
- `PUT /items/:id` — memperbarui data barang (fitur Edit)
- `DELETE /items/:id` — menghapus barang dari katalog saat berhasil dibeli

## 💾 Local Storage

Menggunakan **SharedPreferences** untuk:

- Status onboarding (`isFirstTime`)
- Status login (`isLoggedIn`) dan data akun pengguna yang sedang aktif
- Daftar akun terdaftar (username, email, nomor HP, password)
- **Riwayat nama barang yang pernah dibeli per pengguna** — digunakan untuk mendeteksi otomatis apakah barang yang didaftarkan ulang adalah hasil pembelian sebelumnya

## 📷 Mobile Feature

Aplikasi ini mengimplementasikan **dua** fitur perangkat (rubrik hanya mensyaratkan minimal satu):

1. **Camera** — pengguna wajib mengambil foto barang (via kamera atau galeri) saat mendaftarkan/mengedit barang, menggunakan `image_picker`. Foto disimpan sebagai base64 karena MockAPI tidak menyediakan endpoint upload file.
2. **Local Notification** — notifikasi otomatis muncul setiap kali simulasi pembelian berhasil, menggunakan `flutter_local_notifications`.

## 🛠️ Tech Stack

| Kategori | Package |
|---|---|
| State Management | `provider` |
| HTTP Client | `http` |
| Local Storage | `shared_preferences` |
| Camera/Gallery | `image_picker` |
| Local Notification | `flutter_local_notifications` |
| Onboarding Indicator | `smooth_page_indicator` |

## 🚀 Cara Menjalankan Project

```bash
git clone https://github.com/arielsharonferdinandus/treasure_gatherer_app.git
cd treasure_gatherer_app
flutter pub get
flutter run
```

## 📸 Screenshot Aplikasi

| Landing | Login | Home |
|---|---|---|
| <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/3a22622b-5ab7-4ab4-a80f-032b5bc149fd" /> | <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/c9625d4e-e21a-41cc-b7b3-84afce324f7f" /> | <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/5cd17b13-22f5-4224-8a14-e86f310a3182" />|

| Product Detail | Jual Barang | Notifikasi |
|---|---|---|
| <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/261fa947-0cd3-456b-976a-0300b2ce9cb3" /> | <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/c3826b7d-79cd-40ee-a6a6-481c0c1164c3" /> | <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/ff2da56c-6148-47d1-9dd1-d0bad8424d01" /> |

## 👨‍💻 Rencana Pengembangan Selanjutnya

- Migrasi status "sold" barang ke API
- Autentikasi berbasis token/backend sungguhan menggantikan penyimpanan lokal
- Account Profile and Edit Account pages
- logout account
