import 'pc_component.dart';

/// Mode penyusunan rakitan (KF-01).
enum BuildMode {
  casingFirst('Mode Estetika', 'Mulai dari casing impian'),
  cpuFirst('Mode Kebutuhan', 'Mulai dari beban kerja dan anggaran');

  const BuildMode(this.label, this.deskripsi);
  final String label;
  final String deskripsi;
}

/// Slot rakitan yang dipilih pengguna. Satu slot per jenis komponen wajib;
/// memori dan penyimpanan dapat lebih dari satu unit melalui daftar.
class BuildConfig {
  final BuildMode mode;
  final String? kategoriId;
  final int? budget;
  final PcComponent? casing;
  final PcComponent? cpu;
  final PcComponent? motherboard;
  final PcComponent? gpu;
  final PcComponent? cooler;
  final List<PcComponent> ram;
  final List<PcComponent> storage;
  final PcComponent? psu;

  const BuildConfig({
    this.mode = BuildMode.casingFirst,
    this.kategoriId,
    this.budget,
    this.casing,
    this.cpu,
    this.motherboard,
    this.gpu,
    this.cooler,
    this.ram = const [],
    this.storage = const [],
    this.psu,
  });

  /// Urutan langkah pada Mode Estetika (Casing-First).
  static const List<ComponentType> stepCasingFirst = [
    ComponentType.casing,
    ComponentType.cpu,
    ComponentType.motherboard,
    ComponentType.gpu,
    ComponentType.cooler,
    ComponentType.ram,
    ComponentType.storage,
    ComponentType.psu,
  ];

  /// Urutan langkah pada Mode Kebutuhan (CPU-First).
  static const List<ComponentType> stepCpuFirst = [
    ComponentType.cpu,
    ComponentType.cooler,
    ComponentType.motherboard,
    ComponentType.ram,
    ComponentType.gpu,
    ComponentType.storage,
    ComponentType.psu,
    ComponentType.casing,
  ];

  List<ComponentType> get langkah =>
      mode == BuildMode.casingFirst ? stepCasingFirst : stepCpuFirst;

  PcComponent? slot(ComponentType t) => switch (t) {
        ComponentType.casing => casing,
        ComponentType.cpu => cpu,
        ComponentType.motherboard => motherboard,
        ComponentType.gpu => gpu,
        ComponentType.cooler => cooler,
        ComponentType.ram => ram.isEmpty ? null : ram.first,
        ComponentType.storage => storage.isEmpty ? null : storage.first,
        ComponentType.psu => psu,
      };

  int get jumlahTerpilih =>
      [casing, cpu, motherboard, gpu, cooler, psu].where((e) => e != null).length +
      (ram.isEmpty ? 0 : 1) +
      (storage.isEmpty ? 0 : 1);

  int get jumlahWajib => 8;

  int get progres => ((jumlahTerpilih / jumlahWajib) * 100).round();

  /// Rakitan dinyatakan lengkap bila enam slot wajib tunggal terisi serta
  /// memori dan penyimpanan masing-masing minimal satu unit.
  bool get lengkap =>
      casing != null &&
      cpu != null &&
      motherboard != null &&
      gpu != null &&
      cooler != null &&
      psu != null &&
      ram.isNotEmpty &&
      storage.isNotEmpty;

  List<PcComponent> get semuaKomponen => [
        ?casing,
        ?cpu,
        ?motherboard,
        ?gpu,
        ?cooler,
        ...ram,
        ...storage,
        ?psu,
      ];

  BuildConfig copyWith({
    BuildMode? mode,
    String? kategoriId,
    int? budget,
    PcComponent? casing,
    PcComponent? cpu,
    PcComponent? motherboard,
    PcComponent? gpu,
    PcComponent? cooler,
    List<PcComponent>? ram,
    List<PcComponent>? storage,
    PcComponent? psu,
    bool hapusCasing = false,
    bool hapusCpu = false,
    bool hapusMotherboard = false,
    bool hapusGpu = false,
    bool hapusCooler = false,
    bool hapusPsu = false,
  }) {
    return BuildConfig(
      mode: mode ?? this.mode,
      kategoriId: kategoriId ?? this.kategoriId,
      budget: budget ?? this.budget,
      casing: hapusCasing ? null : (casing ?? this.casing),
      cpu: hapusCpu ? null : (cpu ?? this.cpu),
      motherboard: hapusMotherboard ? null : (motherboard ?? this.motherboard),
      gpu: hapusGpu ? null : (gpu ?? this.gpu),
      cooler: hapusCooler ? null : (cooler ?? this.cooler),
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      psu: hapusPsu ? null : (psu ?? this.psu),
    );
  }
}

/// Rakitan yang sudah tersimpan pada basis data lokal (tabel rakitan).
class SavedBuild {
  const SavedBuild({
    required this.nama,
    required this.config,
    required this.totalHarga,
    required this.totalDayaWatt,
    required this.rekomendasiPsuWatt,
    required this.dibuatPada,
  });

  final String nama;
  final BuildConfig config;
  final int totalHarga;
  final int totalDayaWatt;
  final int rekomendasiPsuWatt;
  final DateTime dibuatPada;
}
