import 'package:intl/intl.dart';

/// Pemformat Rupiah dan satuan teknis (mm, W, GB).
class Fmt {
  static final NumberFormat _rp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(int value) => _rp.format(value);

  /// Ringkas untuk bilah ringkasan, contoh: Rp 22,6 jt.
  static String rupiahRingkas(int value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    }
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    }
    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    }
    return rupiah(value);
  }

  static String watt(int value) => '$value W';
  static String mm(int value) => '$value mm';
  static String gb(int value) => '$value GB';
}
