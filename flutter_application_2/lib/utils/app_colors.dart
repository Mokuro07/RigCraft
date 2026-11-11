import 'package:flutter/material.dart';

/// Palet tema dan warna status kompatibilitas (sub-bab 3.8 dokumen perancangan).
class AppColors {
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF141A26);
  static const Color surfaceAlt = Color(0xFF1D2534);
  static const Color border = Color(0xFF2A3547);
  static const Color textPrimary = Color(0xFFE6EDF7);
  static const Color textSecondary = Color(0xFF93A1B5);

  /// Hijau: komponen kompatibel.
  static const Color compatible = Color(0xFF10B981);

  /// Biru: komponen yang sedang dipilih.
  static const Color selected = Color(0xFF3B82F6);

  /// Amber: peringatan batas daya atau cadangan termal tipis.
  static const Color warning = Color(0xFFF59E0B);

  /// Merah: komponen tidak kompatibel.
  static const Color incompatible = Color(0xFFEF4444);
}
