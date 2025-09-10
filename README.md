# 📱 Split Bill Proporsional

Aplikasi **Flutter** untuk membagi tagihan secara **proporsional** berdasarkan pesanan masing-masing.  
Berbeda dengan split bill biasa, biaya tambahan (pajak, servis, ongkir, dll) **tidak dibagi rata**, tetapi dihitung sesuai porsi pesanan.

✨ Dengan aplikasi ini, yang makan lebih banyak akan bayar pajak/servis lebih banyak → **lebih adil & transparan**.

---

## 🚀 Fitur Utama

-   ✅ **Data Master**:
    -   Daftar Teman
    -   Daftar Menu
    -   Daftar Biaya Tambahan (pajak, servis, ongkir, dll)
-   ✅ **Input Pesanan** → pilih teman & menu, atur qty.
-   ✅ **Perhitungan Proporsional** otomatis.
-   ✅ **Ringkasan per orang** (subtotal, biaya tambahan, total).
-   ✅ **Export hasil ke PDF** → otomatis upload ke **Supabase Storage**.
-   ✅ **Share link PDF** langsung ke WhatsApp, Telegram, atau copy link.
-   ✅ **Riwayat PDF** → semua file tersimpan di Supabase dan bisa dibuka kembali.
-   ✅ **Offline Support** → data master tersimpan di local (SharedPreferences).

---

## 📊 Contoh Perhitungan

**Tagihan Restoran**

-   Subtotal: Rp 140.000
-   Biaya tambahan (service + pajak): Rp 21.500
-   Grand total: Rp 161.500

**Pesanan:**

-   Anita → Rp 49.000
-   Brenda → Rp 12.000
-   Cindy → Rp 21.000
-   Dian → Rp 58.000

**Hasil proporsional:**

-   Anita : Rp 49.000 + Rp 7.525 = **Rp 56.525**
-   Brenda : Rp 12.000 + Rp 1.843 = **Rp 13.843**
-   Cindy : Rp 21.000 + Rp 3.225 = **Rp 24.225**
-   Dian : Rp 58.000 + Rp 8.907 = **Rp 66.907**

✅ Total semua = Rp 161.500 (sama dengan nota).

---

## 🛠️ Teknologi yang Dipakai

-   [Flutter](https://flutter.dev/)
-   [Supabase](https://supabase.com/) (Storage untuk PDF)
-   [SharedPreferences](https://pub.dev/packages/shared_preferences) (local storage)
-   [pdf](https://pub.dev/packages/pdf) (generate PDF)
-   [url_launcher](https://pub.dev/packages/url_launcher) (buka link/share)

---

## 📷 Tampilan Aplikasi

-   Halaman Home → pilih fitur
-   Input Menu & Pesanan
-   Ringkasan per orang
-   Export PDF + Share link
-   Riwayat PDF (dengan opsi buka/share/delete)

---

## ⚙️ Setup Project

1. Clone repo ini
    ```bash
    git clone https://github.com/username/split-bill-proporsional.git
    cd split-bill-proporsional
    ```
