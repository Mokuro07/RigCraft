import 'package:flutter/material.dart';

import '../models/build_config.dart';
import '../utils/app_colors.dart';

/// ModeSwitcher: SegmentedButton pengalih Mode Estetika dan Mode Kebutuhan (KF-01).
class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key, required this.mode, required this.onChanged});

  final BuildMode mode;
  final ValueChanged<BuildMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BuildMode>(
      segments: const [
        ButtonSegment(
          value: BuildMode.casingFirst,
          label: Text('Mode Estetika'),
          icon: Icon(Icons.style_outlined, size: 18),
        ),
        ButtonSegment(
          value: BuildMode.cpuFirst,
          label: Text('Mode Kebutuhan'),
          icon: Icon(Icons.tune, size: 18),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textSecondary,
        selectedBackgroundColor: AppColors.selected,
        selectedForegroundColor: Colors.white,
      ),
    );
  }
}
