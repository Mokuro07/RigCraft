import 'package:flutter/material.dart';

/// Kategori beban kerja (KF-02). Daftar ini dipakai bersama oleh dasbor dan tab
/// Pre-Built; bobotGpu menentukan prioritas penyusunan rakitan otomatis.
class Kategori {
  const Kategori({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.ikon,
  });

  final String id;
  final String nama;
  final String deskripsi;
  final IconData ikon;
}

const List<Kategori> kategoriList = [
  Kategori(
    id: 'GAMING',
    nama: 'Gaming AAA',
    deskripsi: 'Prioritas kartu grafis tinggi',
    ikon: Icons.sports_esports,
  ),
  Kategori(
    id: 'EDITING',
    nama: 'Kreator Konten',
    deskripsi: 'Seimbang prosesor dan grafis',
    ikon: Icons.videocam_outlined,
  ),
  Kategori(
    id: 'DATASCI',
    nama: 'Data Science & AI',
    deskripsi: 'Prioritas inti prosesor',
    ikon: Icons.science_outlined,
  ),
  Kategori(
    id: 'OFFICE',
    nama: 'Office Hemat',
    deskripsi: 'Hemat daya untuk kerja harian',
    ikon: Icons.business_center_outlined,
  ),
];

/// Paket layanan perawatan berkala (UC-10).
class Paket {
  const Paket(this.nama, this.lingkup, this.harga, this.jadwal);
  final String nama;
  final String lingkup;
  final int harga;
  final String jadwal;
}

const List<Paket> paketPerawatan = [
  Paket('Bersih Debu Standar', 'Pembersihan filter dan kipas, pengecekan suhu', 150000,
      'setiap 6 bulan'),
  Paket('Ganti Termal Paste', 'Penggantian pasta termal prosesor dan kartu grafis', 250000,
      'setiap 12 bulan'),
  Paket('Cek Kesehatan Sistem', 'Uji beban, cek catu daya, dan laporan kesehatan', 200000,
      'setiap 12 bulan'),
];
