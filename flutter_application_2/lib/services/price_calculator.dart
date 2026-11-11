import '../models/build_config.dart';

/// Kalkulasi biaya dan pemantauan batas anggaran (KF-06).
class PriceCalculator {
  const PriceCalculator();

  /// total_harga = jumlah harga seluruh komponen terpilih.
  int totalHarga(BuildConfig config) => config.semuaKomponen
      .fold<int>(0, (jumlah, komponen) => jumlah + komponen.harga);

  bool melebihiAnggaran(BuildConfig config) {
    final int? budget = config.budget;
    if (budget == null) return false;
    return totalHarga(config) > budget;
  }

  /// Selisih terhadap anggaran; bernilai negatif bila melampaui batas.
  int? selisihAnggaran(BuildConfig config) {
    final int? budget = config.budget;
    if (budget == null) return null;
    return budget - totalHarga(config);
  }

  double pemakaianAnggaran(BuildConfig config) {
    final int? budget = config.budget;
    if (budget == null || budget == 0) return 0;
    return totalHarga(config) / budget;
  }
}
