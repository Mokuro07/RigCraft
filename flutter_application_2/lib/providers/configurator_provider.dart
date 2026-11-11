import 'package:flutter/foundation.dart';

import '../data/component_repository.dart';
import '../models/build_config.dart';
import '../models/constraint_result.dart';
import '../models/pc_component.dart';
import '../services/constraint_engine.dart';
import '../services/price_calculator.dart';
import '../services/thermal_analyzer.dart';

/// ConfiguratorState: satu sumber kebenaran untuk seluruh pilihan rakitan.
/// Setiap perubahan memicu validasi ulang Constraint Engine dan
/// pemberitahuan kepada widget pendengar (notifyListeners).
class ConfiguratorProvider extends ChangeNotifier {
  ConfiguratorProvider({
    ComponentRepository? repository,
    this.engine = const ConstraintEngine(),
    this.harga = const PriceCalculator(),
    this.termal = const ThermalAnalyzer(),
  }) : repo = repository ?? ComponentRepository();

  final ComponentRepository repo;
  final ConstraintEngine engine;
  final PriceCalculator harga;
  final ThermalAnalyzer termal;

  BuildConfig _config = const BuildConfig();
  BuildConfig get config => _config;

  int _langkah = 0;
  int get langkah => _langkah;

  String? _notifikasi;
  String? get notifikasi => _notifikasi;

  // ------------------------------------------------------------ turunan
  List<ComponentType> get langkahAktif => _config.langkah;
  ComponentType get tipeSaatIni => langkahAktif[_langkah.clamp(0, langkahAktif.length - 1)];

  int get totalHarga => harga.totalHarga(_config);
  int get totalDaya => engine.dayaTotal(cpu: _config.cpu, gpu: _config.gpu);
  int get rekomendasiPsu => engine.rekomendasiPsu(totalDaya);
  bool get melebihiAnggaran => harga.melebihiAnggaran(_config);
  String get statusTermal => termal.statusTermal(_config);

  List<PcComponent> kandidat(ComponentType t) => repo.byType(t);

  ConstraintResult status(PcComponent k) => engine.periksa(k, _config);

  /// Kandidat yang boleh dipilih pada langkah saat ini.
  List<PcComponent> get kandidatTersedia =>
      kandidat(tipeSaatIni).where((k) => status(k).bolehDipilih).toList();

  // ------------------------------------------------------------ aksi
  void gantiMode(BuildMode mode) {
    if (_config.mode == mode) return;
    _config = _config.copyWith(mode: mode);
    _langkah = 0;
    _notifikasi = 'Mode diubah ke ${mode.label}. Langkah pemilihan disusun ulang.';
    notifyListeners();
  }

  void aturAnggaran(int budget) {
    _config = _config.copyWith(budget: budget);
    notifyListeners();
  }

  void aturKategori(String kategoriId) {
    _config = _config.copyWith(kategoriId: kategoriId);
    notifyListeners();
  }

  void pilih(PcComponent komponen) {
    final hasil = engine.periksa(komponen, _config);
    if (!hasil.bolehDipilih) {
      _notifikasi = hasil.alasanUtama?.pesan ?? 'Komponen tidak kompatibel.';
      notifyListeners();
      return;
    }
    switch (komponen.type) {
      case ComponentType.casing:
        _config = _config.copyWith(casing: komponen);
      case ComponentType.cpu:
        _config = _config.copyWith(cpu: komponen);
      case ComponentType.motherboard:
        _config = _config.copyWith(motherboard: komponen);
      case ComponentType.gpu:
        _config = _config.copyWith(gpu: komponen);
      case ComponentType.cooler:
        _config = _config.copyWith(cooler: komponen);
      case ComponentType.ram:
        _config = _config.copyWith(ram: [komponen]);
      case ComponentType.storage:
        _config = _config.copyWith(storage: [komponen]);
      case ComponentType.psu:
        _config = _config.copyWith(psu: komponen);
    }
    _jalankanAutoReset();
    _majuLangkah();
    notifyListeners();
  }

  /// Aturan 7: validasi ulang komponen hilir setelah komponen hulu berubah.
  void _jalankanAutoReset() {
    final List<({ComponentType slot, String pesan})> reset =
        engine.resolusiKonflik(_config);
    if (reset.isEmpty) return;
    var kerja = _config;
    for (final r in reset) {
      kerja = switch (r.slot) {
        ComponentType.motherboard => kerja.copyWith(hapusMotherboard: true),
        ComponentType.gpu => kerja.copyWith(hapusGpu: true),
        ComponentType.cooler => kerja.copyWith(hapusCooler: true),
        ComponentType.psu => kerja.copyWith(hapusPsu: true),
        ComponentType.ram => kerja.copyWith(ram: const []),
        _ => kerja,
      };
    }
    _config = kerja;
    _notifikasi = reset.map((e) => e.pesan).join('  |  ');
  }

  void _majuLangkah() {
    if (_langkah < langkahAktif.length - 1 && _config.slot(tipeSaatIni) != null) {
      _langkah++;
    }
  }

  void keLangkah(int i) {
    final int baru = i.clamp(0, langkahAktif.length - 1);
    if (baru == _langkah) return;
    _langkah = baru;
    notifyListeners();
  }

  void mundur() => keLangkah(_langkah - 1);
  void maju() => keLangkah(_langkah + 1);

  void bersihkan() {
    _config = BuildConfig(mode: _config.mode, kategoriId: _config.kategoriId,
        budget: _config.budget);
    _langkah = 0;
    _notifikasi = 'Pilihan dikosongkan.';
    notifyListeners();
  }

  void bersihkanNotifikasi() {
    _notifikasi = null;
  }

  // ------------------------------------------------------------ penyimpanan
  List<SavedBuild> get riwayat => repo.riwayat;

  bool simpan(String nama) {
    if (!_config.lengkap) {
      _notifikasi = 'Rakitan belum lengkap. Lengkapi seluruh langkah dahulu.';
      notifyListeners();
      return false;
    }
    repo.simpan(SavedBuild(
      nama: nama,
      config: _config,
      totalHarga: totalHarga,
      totalDayaWatt: totalDaya,
      rekomendasiPsuWatt: rekomendasiPsu,
      dibuatPada: DateTime.now(),
    ));
    _notifikasi = 'Rakitan "$nama" tersimpan.';
    notifyListeners();
    return true;
  }

  void muatRakitan(BuildConfig config) {
    _config = config;
    _langkah = 0;
    _notifikasi = 'Rakitan dimuat ke konfigurator.';
    notifyListeners();
  }
}
