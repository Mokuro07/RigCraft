import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'power_meter.dart';
import 'thermal_gauge.dart';

/// StickyBottomSummaryBar: ringkasan biaya, daya, dan termal yang tetap
/// berada di bawah layar konfigurator (KF-06).
class StickyBottomSummaryBar extends StatelessWidget {
  const StickyBottomSummaryBar({
    super.key,
    required this.totalHarga,
    required this.budget,
    required this.dayaTotal,
    required this.rekomendasiPsu,
    required this.statusTermal,
    required this.rasioTermal,
    required this.progres,
    required this.onLihatRingkasan,
  });

  final int totalHarga;
  final int? budget;
  final int dayaTotal;
  final int rekomendasiPsu;
  final String statusTermal;
  final double? rasioTermal;
  final int progres;
  final VoidCallback onLihatRingkasan;

  bool get _lewat => budget != null && totalHarga > budget!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total rakitan',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                    Text(
                      Fmt.rupiah(totalHarga),
                      style: TextStyle(
                        color: _lewat ? AppColors.incompatible : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (budget != null)
                      Text(
                        _lewat
                            ? 'Lewat anggaran ${Fmt.rupiah(totalHarga - budget!)}'
                            : 'Sisa anggaran ${Fmt.rupiah(budget! - totalHarga)}',
                        style: TextStyle(
                          color: _lewat ? AppColors.incompatible : AppColors.compatible,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: PowerMeter(dayaTotal: dayaTotal, rekomendasi: rekomendasiPsu),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ThermalGauge(status: statusTermal, rasio: rasioTermal)),
              Text('Langkah $progres%',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onLihatRingkasan,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Ringkasan rakitan'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.selected),
            ),
          ),
        ],
      ),
    );
  }
}
