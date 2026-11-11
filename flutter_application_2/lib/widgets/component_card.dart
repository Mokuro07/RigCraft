import 'package:flutter/material.dart';

import '../models/constraint_result.dart';
import '../models/pc_component.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'compatibility_badge.dart';

/// ComponentCard: kartu satu komponen kandidat pada galeri langkah pemilihan.
///
/// Komponen yang tidak kompatibel tetap ditampilkan dengan penanda merah dan
/// lencana alasan, bukan dihapus dari daftar (prinsip umpan balik elaboratif,
/// KF-04). Menekannya membuka lembar penjelasan, bukan langsung gagal diam.
class ComponentCard extends StatelessWidget {
  const ComponentCard({
    super.key,
    required this.komponen,
    required this.status,
    required this.onTap,
    this.lebar = 230,
  });

  final PcComponent komponen;
  final ConstraintResult status;
  final VoidCallback onTap;

  /// Lebar kartu. Galeri langkah memakai 230 px agar dapat digulir mendatar;
  /// dasbor memakai [double.infinity] agar kartu memenuhi lebar layar.
  final double lebar;

  @override
  Widget build(BuildContext context) {
    final bool mati = !status.bolehDipilih;
    return Opacity(
      opacity: mati ? 0.62 : 1,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: lebar,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status.status == CompatStatus.terpilih
                    ? AppColors.selected
                    : AppColors.border,
                width: status.status == CompatStatus.terpilih ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        komponen.type.label,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                    CompatibilityBadge(status: status.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  komponen.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...komponen.specRingkas.take(2).map(
                          (s) => Text(
                            '•  $s',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                    if (status.butuhPerhatian)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          status.alasanUtama!.pesan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  Fmt.rupiah(komponen.harga),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
