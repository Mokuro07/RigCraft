import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Judul bagian dengan satu baris keterangan, dipakai berulang di keempat tab.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.judul, required this.keterangan});

  final String judul;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(keterangan,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
      ],
    );
  }
}
