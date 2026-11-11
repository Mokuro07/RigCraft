import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kategori_data.dart';
import '../models/build_config.dart';
import '../models/pc_component.dart';
import '../providers/configurator_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/section_header.dart';

/// PrebuiltScreen: halaman rekomendasi rakitan siap pakai (KF-02).
///
/// Memilih satu kategori akan menyusun rakitan otomatis: untuk setiap langkah
/// pada Mode Kebutuhan, sistem mengambil komponen termurah yang lolos seluruh
/// aturan Constraint Engine. Bila anggaran belum mencukupi, sistem tetap
/// menampilkan rakitan termurah yang kompatibel beserta pemberitahuannya.
class PrebuiltScreen extends StatefulWidget {
  const PrebuiltScreen({super.key});

  @override
  State<PrebuiltScreen> createState() => _PrebuiltScreenState();
}

class _PrebuiltScreenState extends State<PrebuiltScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConfiguratorProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          judul: 'Rekomendasi rakitan',
          keterangan: 'Pilih kategori beban kerja, lalu susun rekomendasi otomatis',
        ),
        const SizedBox(height: 8),
        if (p.config.budget != null)
          Text('Anggaran aktif: ${Fmt.rupiah(p.config.budget!)}',
              style: const TextStyle(color: AppColors.compatible, fontSize: 12))
        else
          const Text(
            'Isi batas anggaran pada tab Smart Builder agar rekomendasi dapat '
            'dibandingkan terhadap anggaran Anda.',
            style: TextStyle(color: AppColors.warning, fontSize: 12),
          ),
        const SizedBox(height: 16),
        for (final k in kategoriList) ...[
          Card(
            color: AppColors.surface,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: p.config.kategoriId == k.id
                    ? AppColors.selected
                    : AppColors.border,
                width: p.config.kategoriId == k.id ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(k.ikon, color: AppColors.selected, size: 20),
              title: Text(k.nama,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              subtitle: Text(k.deskripsi,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textSecondary),
              onTap: () => _susun(context, p, k),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        const SectionHeader(
          judul: 'Rakitan hasil rekomendasi',
          keterangan: 'Nilai turunan dihitung ulang oleh Constraint Engine',
        ),
        const SizedBox(height: 10),
        if (p.config.semuaKomponen.isEmpty)
          const Text('Belum ada rekomendasi yang disusun.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5))
        else
          for (final PcComponent c in p.config.semuaKomponen)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${c.type.label}: ${c.nama}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  Text(Fmt.rupiahRingkas(c.harga),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 12)),
                ],
              ),
            ),
        if (p.config.semuaKomponen.isNotEmpty) ...[
          const Divider(color: AppColors.border, height: 24),
          Text('Total ${Fmt.rupiah(p.totalHarga)}  •  Daya ${p.totalDaya} W  •  '
              'PSU ${p.rekomendasiPsu} W',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }

  void _susun(BuildContext context, ConfiguratorProvider p, Kategori kategori) {
    p.aturKategori(kategori.id);
    p.gantiMode(BuildMode.cpuFirst);
    final bool berhasil = _susunOtomatis(p, kategori.id);
    final n = p.notifikasi;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(n ??
            (berhasil
                ? 'Rekomendasi ${kategori.nama} dimuat. Total ${Fmt.rupiah(p.totalHarga)}.'
                : 'Anggaran belum mencukupi untuk kategori ${kategori.nama}. Sistem '
                    'menampilkan rakitan termurah yang kompatibel.')),
        backgroundColor: AppColors.surfaceAlt,
        behavior: SnackBarBehavior.floating,
      ));
    p.bersihkanNotifikasi();
  }

  /// Memilih komponen termurah yang boleh dipakai untuk tiap slot, mengikuti
  /// urutan Mode Kebutuhan. Mengembalikan false bila hasilnya melebihi anggaran.
  bool _susunOtomatis(ConfiguratorProvider p, String kategoriId) {
    p.bersihkan();
    for (final ComponentType t in p.langkahAktif) {
      for (final PcComponent k in p.kandidat(t)) {
        if (p.status(k).bolehDipilih) {
          p.pilih(k);
          break;
        }
      }
    }
    if (p.config.budget == null) return true;
    return !p.melebihiAnggaran;
  }
}
