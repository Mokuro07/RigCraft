import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/build_config.dart';
import '../models/constraint_result.dart';
import '../models/pc_component.dart';
import '../providers/configurator_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/component_card.dart';
import '../widgets/dashboard_cards.dart';
import '../widgets/explanation_sheet.dart';
import '../widgets/mode_switcher.dart';
import '../widgets/section_header.dart';
import '../widgets/sticky_bottom_summary_bar.dart';

/// BuilderScreen: halaman perakitan penuh. Dibuka dari tombol (+) pada dasbor.
///
/// Berisi pengalih mode, batas anggaran, chip langkah pemilihan, dan galeri
/// komponen kandidat (KF-01, KF-03, KF-04, KF-05). Bilah ringkasan
/// biaya/daya/termal tetap berada di bawah layar (KF-06).
class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  final TextEditingController _budget = TextEditingController();

  @override
  void initState() {
    super.initState();
    final BuildConfig config = context.read<ConfiguratorProvider>().config;
    if (config.budget != null) _budget.text = config.budget.toString();
  }

  @override
  void dispose() {
    _budget.dispose();
    super.dispose();
  }

  /// Menampilkan notifikasi provider sebagai SnackBar lalu membersihkannya.
  void _pesan(ConfiguratorProvider p) {
    final String? n = p.notifikasi;
    if (n == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(n),
          backgroundColor: AppColors.surfaceAlt,
          behavior: SnackBarBehavior.floating,
        ));
      p.bersihkanNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConfiguratorProvider>();
    _pesan(p);

    final ComponentType tipe = p.tipeSaatIni;
    final List<PcComponent> kandidat = p.kandidat(tipe);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Perakitan',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Ringkasan rakitan',
            onPressed: () => _dialogRingkasan(p),
            icon: const Icon(Icons.receipt_long, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const SectionHeader(
                  judul: 'Mode penyusunan',
                  keterangan: 'Urutan langkah pemilihan komponen',
                ),
                const SizedBox(height: 10),
                ModeSwitcher(mode: p.config.mode, onChanged: p.gantiMode),
                const SizedBox(height: 22),
                const SectionHeader(
                  judul: 'Anggaran & langkah',
                  keterangan: 'Isi batas anggaran, lalu ikuti langkah pemilihan',
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budget,
                        keyboardType: TextInputType.number,
                        style:
                            const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Batas anggaran (Rp)',
                          labelStyle: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final int? n = int.tryParse(v.replaceAll('.', ''));
                          p.aturAnggaran(n ?? 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        _budget.clear();
                        p.bersihkan();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.langkahAktif.length,
                    itemBuilder: (context, i) {
                      final ComponentType t = p.langkahAktif[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: LangkahChip(
                          nomor: i + 1,
                          label: t.label,
                          aktif: i == p.langkah,
                          terisi: p.config.slot(t) != null,
                          onTap: () => p.keLangkah(i),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                SectionHeader(
                  judul: tipe.label,
                  keterangan: '${kandidat.length} komponen pada katalog '
                      '• ${p.kandidatTersedia.length} dapat dipilih',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kandidat.length,
                    itemBuilder: (context, i) {
                      final PcComponent k = kandidat[i];
                      final ConstraintResult s = p.status(k);
                      return Padding(
                        padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                        child: SizedBox(
                          height: 268,
                          child: ComponentCard(
                            komponen: k,
                            status: s,
                            onTap: () {
                              if (s.bolehDipilih) {
                                p.pilih(k);
                              } else {
                                tampilkanPenjelasan(context, k, s);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          StickyBottomSummaryBar(
            totalHarga: p.totalHarga,
            budget: p.config.budget,
            dayaTotal: p.totalDaya,
            rekomendasiPsu: p.rekomendasiPsu,
            statusTermal: p.statusTermal,
            rasioTermal: p.termal.cadanganTermal(p.config),
            progres: p.config.progres,
            onLihatRingkasan: () => _dialogRingkasan(p),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogRingkasan(ConfiguratorProvider p) async {
    final TextEditingController nama = TextEditingController(text: 'Rakitan Saya');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ringkasan rakitan',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final k in p.config.semuaKomponen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${k.type.label}: ${k.nama}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                      Text(Fmt.rupiahRingkas(k.harga),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                ),
              const Divider(color: AppColors.border),
              Text('Total: ${Fmt.rupiah(p.totalHarga)}',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              Text('Daya ${p.totalDaya} W, rekomendasi PSU ${p.rekomendasiPsu} W',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: 160,
            child: TextField(
              controller: nama,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Nama rakitan',
                labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              p.simpan(nama.text);
              Navigator.of(context).pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
