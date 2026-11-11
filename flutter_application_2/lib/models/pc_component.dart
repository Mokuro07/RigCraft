/// Jenis komponen. Delapan nilai ini sejajar dengan delapan tabel pada ERD
/// (Gambar 3.4) dan delapan tabel SQLite pada skema.sql.
enum ComponentType {
  casing, cpu, motherboard, gpu, cooler, ram, storage, psu;

  String get label => switch (this) {
        ComponentType.casing => 'Casing',
        ComponentType.cpu => 'Prosesor',
        ComponentType.motherboard => 'Motherboard',
        ComponentType.gpu => 'Kartu Grafis',
        ComponentType.cooler => 'Pendingin CPU',
        ComponentType.ram => 'Memori',
        ComponentType.storage => 'Penyimpanan',
        ComponentType.psu => 'Catu Daya',
      };
}

/// Entitas komponen tunggal dengan kolom spesifik per jenis bernilai null bila
/// tidak berlaku. Bentuk ini mencerminkan pola tabel terpisah (disjoint entity)
/// pada basis data: kolom bersama ada di semua jenis, kolom teknis hanya terisi
/// pada jenis yang memilikinya.
class PcComponent {
  final ComponentType type;
  final String id;
  final String nama;
  final int harga;

  // casing
  final String? supportedFormFactors;
  final int? maxGpuLengthMm;
  final int? maxCoolerHeightMm;
  final String? supportedRadiator;
  final String? psuFormFactor;

  // cpu / motherboard
  final String? socketType;
  final int? coreCount;
  final int? baseTdpWatt;
  final int? peakTdpWatt;
  final String? formFactor;
  final String? ramType;
  final int? ramSlots;
  final int? maxRamSpeed;

  // gpu
  final int? vramGb;
  final int? tdpWatt;
  final int? lengthMm;

  // cooler
  final String? coolerType;
  final int? maxTdpWatt;
  final int? heightMm;
  final int? radiatorSize;

  // ram / storage
  final int? capacityGb;
  final int? speedMhz;
  final int? modules;
  final int? readMbps;
  final String? storageInterface;

  // psu
  final int? wattage;
  final String? efficiency;

  final String? kategoriId;
  final String? imageAsset;

  const PcComponent({
    required this.type,
    required this.id,
    required this.nama,
    required this.harga,
    this.supportedFormFactors,
    this.maxGpuLengthMm,
    this.maxCoolerHeightMm,
    this.supportedRadiator,
    this.psuFormFactor,
    this.socketType,
    this.coreCount,
    this.baseTdpWatt,
    this.peakTdpWatt,
    this.formFactor,
    this.ramType,
    this.ramSlots,
    this.maxRamSpeed,
    this.vramGb,
    this.tdpWatt,
    this.lengthMm,
    this.coolerType,
    this.maxTdpWatt,
    this.heightMm,
    this.radiatorSize,
    this.capacityGb,
    this.speedMhz,
    this.modules,
    this.readMbps,
    this.storageInterface,
    this.wattage,
    this.efficiency,
    this.kategoriId,
    this.imageAsset,
  });

  List<String> get formFactors =>
      (supportedFormFactors ?? '').split(',').where((e) => e.isNotEmpty).toList();

  List<int> get radiators => (supportedRadiator ?? '')
      .split(',')
      .where((e) => e.isNotEmpty)
      .map(int.parse)
      .toList();

  /// Spesifikasi kunci untuk ditampilkan pada kartu komponen.
  List<String> get specRingkas => switch (type) {
        ComponentType.casing => [
            ?supportedFormFactors,
            if (maxGpuLengthMm != null) 'GPU maks $maxGpuLengthMm mm',
            if (maxCoolerHeightMm != null) 'Cooler maks $maxCoolerHeightMm mm',
            ?supportedRadiator == null ? null : 'AIO $supportedRadiator mm',
          ],
        ComponentType.cpu => [
            ?socketType,
            if (coreCount != null) '$coreCount inti',
            if (peakTdpWatt != null) 'TDP puncak $peakTdpWatt W',
          ],
        ComponentType.motherboard => [
            ?socketType,
            ?formFactor,
            ?ramType,
          ],
        ComponentType.gpu => [
            if (vramGb != null) '$vramGb GB',
            if (lengthMm != null) '$lengthMm mm',
            if (tdpWatt != null) '$tdpWatt W',
          ],
        ComponentType.cooler => [
            ?coolerType,
            if (maxTdpWatt != null) 'hingga $maxTdpWatt W',
            if (heightMm != null) 'tinggi $heightMm mm',
            if (radiatorSize != null) 'radiator $radiatorSize mm',
          ],
        ComponentType.ram => [
            ?ramType,
            if (capacityGb != null) '$capacityGb GB',
            if (speedMhz != null) '$speedMhz MHz',
          ],
        ComponentType.storage => [
            ?storageInterface,
            if (capacityGb != null) '$capacityGb GB',
            if (readMbps != null) '$readMbps MB/s',
          ],
        ComponentType.psu => [
            if (wattage != null) '$wattage W',
            ?efficiency,
            ?psuFormFactor,
          ],
      };
}
