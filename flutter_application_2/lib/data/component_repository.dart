import '../models/build_config.dart';
import '../models/pc_component.dart';
import 'seed_data.dart';

/// Repositori katalog komponen (lapisan data).
///
/// Fase MVP memuat katalog dari [seedKomponen] di dalam memori sehingga aplikasi
/// tetap dapat dipakai tanpa jaringan (KF-07, BB-08). Penggantian ke pembacaan
/// tabel SQLite dilakukan pada tahap lanjutan tanpa mengubah kontrak kelas ini.
class ComponentRepository {
  final List<PcComponent> _all = List<PcComponent>.of(seedKomponen);
  final List<SavedBuild> _tersimpan = [];

  List<PcComponent> get semua => List.unmodifiable(_all);

  List<PcComponent> byType(ComponentType t) =>
      _all.where((c) => c.type == t).toList();

  PcComponent? byId(String id) {
    for (final c in _all) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<SavedBuild> get riwayat =>
      List.unmodifiable(_tersimpan.reversed.toList());

  /// Menyimpan rakitan beserta nilai turunan hasil hitung saat penyimpanan,
  /// meniru kolom total_harga, total_daya_watt, dan rekomendasi_psu_watt pada
  /// tabel rakitan (sub-bab 3.4.5 dokumen perancangan).
  void simpan(SavedBuild build) => _tersimpan.add(build);

  void hapus(String nama) =>
      _tersimpan.removeWhere((b) => b.nama == nama);
}
