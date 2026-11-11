import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// ThermalGauge: indikator keseimbangan termal pada bilah ringkasan (KF-06).
class ThermalGauge extends StatelessWidget {
  const ThermalGauge({super.key, required this.status, required this.rasio});

  final String status;
  final double? rasio;

  Color get warna {
    if (rasio == null) return AppColors.textSecondary;
    if (rasio! < 1.0) return AppColors.incompatible;
    if (rasio! < 1.15) return AppColors.warning;
    return AppColors.compatible;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.thermostat, size: 15, color: warna),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            status,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: warna, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        if (rasio != null) ...[
          const SizedBox(width: 6),
          Text('x${rasio!.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ],
    );
  }
}
