import 'package:flutter/material.dart';

import '../data/kategori_data.dart';
import '../utils/app_colors.dart';

/// Kartu sambutan pada awal dasbor.
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key, required this.onMulai});

  final VoidCallback onMulai;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.selected.withValues(alpha: 0.30),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat datang di RigCraft',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Susun rakitan PC impianmu, sistem akan memeriksa kecocokan setiap '
            'komponen sebelum kamu membelinya.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onMulai,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Mulai menyusun rakitan'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.selected),
          ),
        ],
      ),
    );
  }
}

/// Kartu angka ringkas: anggaran, daya, atau jumlah slot terisi (KF-06).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  final String label;
  final String nilai;
  final IconData ikon;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 16, color: warna),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(nilai,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// Kartu kategori beban kerja yang dapat digulir mendatar (KF-02).
/// Kategori terpilih ditandai bingkai biru agar terlihat mana yang sedang aktif.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.kategori,
    required this.terpilih,
    required this.onTap,
  });

  final Kategori kategori;
  final bool terpilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: terpilih ? AppColors.selected : AppColors.border,
                width: terpilih ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.selected.withValues(alpha: terpilih ? 0.30 : 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(kategori.ikon, size: 18, color: AppColors.selected),
                ),
                const Spacer(),
                Text(kategori.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(kategori.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11.5, height: 1.35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip satu langkah pemilihan komponen pada konfigurator (KF-03).
class LangkahChip extends StatelessWidget {
  const LangkahChip({
    super.key,
    required this.nomor,
    required this.label,
    required this.aktif,
    required this.terisi,
    required this.onTap,
  });

  final int nomor;
  final String label;
  final bool aktif;
  final bool terisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        terisi ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 16,
        color: terisi ? AppColors.compatible : AppColors.textSecondary,
      ),
      label: Text('$nomor. $label',
          style: TextStyle(
              fontSize: 11, color: aktif ? Colors.white : AppColors.textSecondary)),
      backgroundColor: aktif ? AppColors.selected : AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }
}
