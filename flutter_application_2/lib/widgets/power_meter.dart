import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// PowerMeter: indikator daya listrik pada bilah ringkasan (KF-06).
class PowerMeter extends StatelessWidget {
  const PowerMeter({
    super.key,
    required this.dayaTotal,
    required this.rekomendasi,
  });

  final int dayaTotal;
  final int rekomendasi;

  @override
  Widget build(BuildContext context) {
    final double rasio = rekomendasi == 0 ? 0 : (dayaTotal / rekomendasi).clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Text('$dayaTotal W',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Flexible(
              child: Text(
                'PSU $rekomendasi W',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: rasio,
            minHeight: 5,
            backgroundColor: AppColors.surfaceAlt,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
          ),
        ),
      ],
    );
  }
}
