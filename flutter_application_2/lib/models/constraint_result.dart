/// Kelas status komponen pada antarmuka (KF-04).
enum CompatStatus {
  kompatibel('Cocok', 0),
  terpilih('Dipilih', 1),
  peringatan('Perhatian', 2),
  tidakKompatibel('Tidak cocok', 3);

  const CompatStatus(this.label, this.urutan);
  final String label;
  final int urutan;
}

/// Satu alasan ketidakcocokan beserta saran perbaikan.
/// Inilah wujud umpan balik elaboratif: bukan sekadar menolak, tetapi
/// menjelaskan nilai yang bertentangan dan menawarkan komponen pengganti.
class ConstraintReason {
  const ConstraintReason({
    required this.kode,
    required this.pesan,
    required this.terperinci,
    this.saran,
    this.fatal = true,
  });

  final String kode;
  final String pesan;
  final String terperinci;
  final String? saran;

  /// Benar bila alasan ini membuat komponen tidak boleh dipakai sama sekali.
  /// Alasan non-fatal hanya menaikkan status menjadi peringatan.
  final bool fatal;
}

/// Hasil validasi satu komponen kandidat.
class ConstraintResult {
  const ConstraintResult(this.status, {this.alasan = const []});

  final CompatStatus status;
  final List<ConstraintReason> alasan;

  bool get terpilih => status == CompatStatus.terpilih;
  bool get bolehDipilih =>
      status == CompatStatus.kompatibel ||
      status == CompatStatus.terpilih ||
      status == CompatStatus.peringatan;
  bool get butuhPerhatian => alasan.isNotEmpty;

  ConstraintReason? get alasanUtama => alasan.isEmpty ? null : alasan.first;
}
