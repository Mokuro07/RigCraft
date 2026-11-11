import 'package:flutter/material.dart';

import '../models/constraint_result.dart';
import '../models/pc_component.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';

/// Lembar penjelasan bawah (showModalBottomSheet) yang menampilkan alasan
/// teknis ketidakcocokan beserta saran perbaikan (KF-04).
Future<void> tampilkanPenjelasan(
  BuildContext context,
  PcComponent komponen,
  ConstraintResult status,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(komponen.nama,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${komponen.type.label}  •  ${Fmt.rupiah(komponen.harga)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            if (status.alasan.isEmpty)
              const Text('Komponen ini kompatibel dengan pilihan Anda saat ini.',
                  style: TextStyle(color: AppColors.compatible, fontSize: 13))
            else
              ...status.alasan.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: status.status == CompatStatus.tidakKompatibel
                              ? AppColors.incompatible
                              : AppColors.warning),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(r.kode,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r.pesan,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r.terperinci,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.45)),
                        if (r.saran != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  size: 15, color: AppColors.compatible),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(r.saran!,
                                    style: const TextStyle(
                                        color: AppColors.compatible,
                                        fontSize: 12.5,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  )),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: AppColors.surfaceAlt),
                child: const Text('Mengerti'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
