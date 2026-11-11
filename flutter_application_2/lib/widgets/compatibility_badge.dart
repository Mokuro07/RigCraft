import 'package:flutter/material.dart';

import '../models/constraint_result.dart';
import '../utils/app_colors.dart';

/// CompatibilityBadge: lencana status komponen berwarna (KF-04).
class CompatibilityBadge extends StatelessWidget {
  const CompatibilityBadge({super.key, required this.status});

  final CompatStatus status;

  Color get warna => switch (status) {
        CompatStatus.kompatibel => AppColors.compatible,
        CompatStatus.terpilih => AppColors.selected,
        CompatStatus.peringatan => AppColors.warning,
        CompatStatus.tidakKompatibel => AppColors.incompatible,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: warna, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(color: warna, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
