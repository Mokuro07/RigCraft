import 'package:flutter/material.dart';

import '../data/kategori_data.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';

/// Kartu satu paket layanan perawatan berkala (UC-10).
class PaketCard extends StatelessWidget {
  const PaketCard({super.key, required this.paket, required this.onPesan});

  final Paket paket;
  final VoidCallback onPesan;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(paket.nama,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(paket.lingkup,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(Fmt.rupiah(paket.harga),
                      style: const TextStyle(
                          color: AppColors.compatible,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                Flexible(
                  child: Text(paket.jadwal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onPesan,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.selected,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Pesan', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
