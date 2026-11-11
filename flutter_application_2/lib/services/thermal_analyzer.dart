import '../models/build_config.dart';
import '../models/pc_component.dart';

/// Analisis keseimbangan termal dan daya untuk bilah ringkasan (KF-06).
class ThermalAnalyzer {
  const ThermalAnalyzer();

  /// Rasio cadangan termal pendingin terhadap TDP puncak prosesor.
  double? cadanganTermal(BuildConfig config) {
    final PcComponent? cpu = config.cpu;
    final PcComponent? cooler = config.cooler;
    if (cpu?.peakTdpWatt == null || cooler?.maxTdpWatt == null) return null;
    return cooler!.maxTdpWatt! / cpu!.peakTdpWatt!;
  }

  /// Label status termal untuk indikator pada antarmuka.
  String statusTermal(BuildConfig config) {
    final double? rasio = cadanganTermal(config);
    if (rasio == null) return 'Belum lengkap';
    if (rasio < 1.0) return 'Risiko throttling';
    if (rasio < 1.15) return 'Cadangan tipis';
    if (rasio < 1.5) return 'Aman';
    return 'Sangat lega';
  }
}
