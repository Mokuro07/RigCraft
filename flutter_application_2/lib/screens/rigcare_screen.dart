import 'package:flutter/material.dart';

import '../data/kategori_data.dart';
import '../utils/app_colors.dart';
import '../widgets/paket_card.dart';
import '../widgets/section_header.dart';

/// RigCareScreen: halaman daftar paket layanan perawatan berkala (UC-10).
///
/// Pemesanan belum tersambung ke basis data, jadi tombol Pesan baru
/// mengembalikan ringkasan singkat paket yang dipilih.
class RigCareScreen extends StatelessWidget {
  const RigCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(
          judul: 'RigCare+',
          keterangan: 'Layanan perawatan berkala dan garansi satu pintu',
        ),
        const SizedBox(height: 16),
        for (final p in paketPerawatan) ...[
          PaketCard(paket: p, onPesan: () => _pesan(context, p)),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _pesan(BuildContext context, Paket paket) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(paket.nama,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        content: Text(
          '${paket.lingkup}.\n\nJadwal disarankan: ${paket.jadwal}.\n'
          'Pemesanan akan tersedia pada tahap berikutnya.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}
