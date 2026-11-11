import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kategori_data.dart';
import '../models/pc_component.dart';
import '../providers/configurator_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/component_card.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/explanation_sheet.dart';
import '../widgets/section_header.dart';
import 'builder_screen.dart';

/// DashboardScreen: halaman utama yang hanya menampilkan ringkasan rakitan.
///
/// Penyusunan komponen tidak lagi dilakukan di sini; tombol mengambang (+) dan
/// tombol pada kartu sambutan membuka [BuilderScreen] yang berisi mode
/// penyusunan, batas anggaran, langkah pemilihan, dan galeri komponen.
/// Hasil pilihan langsung tampil pada dasbor ini.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConfiguratorProvider>();
    final List<PcComponent> terpilih = p.config.semuaKomponen;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaPerakitan(context),
        backgroundColor: AppColors.selected,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(terpilih.isEmpty ? 'Susun rakitan' : 'Lanjut menyusun'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          WelcomeCard(onMulai: () => _bukaPerakitan(context)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Anggaran',
                  nilai: p.config.budget == null
                      ? '—'
                      : Fmt.rupiahRingkas(p.config.budget!),
                  ikon: Icons.savings,
                  warna: p.melebihiAnggaran
                      ? AppColors.incompatible
                      : AppColors.selected,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Daya',
                  nilai: '${p.totalDaya} W',
                  ikon: Icons.bolt,
                  warna: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  label: 'Slot',
                  nilai: '${p.config.jumlahTerpilih} / ${p.config.jumlahWajib}',
                  ikon: Icons.grid_view,
                  warna:
                      p.config.lengkap ? AppColors.compatible : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionHeader(
            judul: 'Kategori beban kerja',
            keterangan: 'Menentukan prioritas komponen',
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kategoriList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final k = kategoriList[i];
                return CategoryCard(
                  kategori: k,
                  terpilih: p.config.kategoriId == k.id,
                  onTap: () {
                    p.aturKategori(k.id);
                    _pesan(context,
                        'Kategori ${k.nama} dipilih. Buka perakitan untuk menyusunnya.');
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            judul: 'Komponen terpilih',
            keterangan: terpilih.isEmpty
                ? 'Belum ada komponen yang dipilih'
                : 'Progres rakitan ${p.config.progres}%',
          ),
          const SizedBox(height: 10),
          if (terpilih.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Tekan tombol + di kanan bawah untuk mulai memilih komponen.\n'
                'Setiap pilihan langsung muncul di sini.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
              ),
            )
          else
            for (final PcComponent k in terpilih)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ComponentCard(
                  komponen: k,
                  status: p.status(k),
                  lebar: double.infinity,
                  onTap: () => tampilkanPenjelasan(context, k, p.status(k)),
                ),
              ),
          if (terpilih.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _bukaPerakitan(context),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Ubah pilihan komponen'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceAlt,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _bukaPerakitan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BuilderScreen()),
    );
  }

  void _pesan(BuildContext context, String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(teks),
        backgroundColor: AppColors.surfaceAlt,
        behavior: SnackBarBehavior.floating,
      ));
  }
}
