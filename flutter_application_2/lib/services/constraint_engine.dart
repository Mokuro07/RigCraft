import '../models/build_config.dart';
import '../models/constraint_result.dart';
import '../models/pc_component.dart';

/// Constraint Engine: tujuh aturan deterministik pada sub-bab 3.6 dokumen
/// perancangan. Seluruh metode bersifat murni (tanpa keadaan internal) sehingga
/// hasilnya dapat diuji langsung pada berkas test.
class ConstraintEngine {
  const ConstraintEngine();

  /// Daya dasar sistem untuk motherboard, memori, penyimpanan, dan kipas.
  static const int dayaDasarWatt = 80;

  /// Faktor margin keamanan daya (30 persen).
  static const double alpha = 1.3;

  /// Ambang peringatan ruang bebas panjang kartu grafis.
  static const int deltaMm = 15;

  /// Ambang peringatan cadangan termal pendingin.
  static const double epsilon = 1.15;

  // ---------------------------------------------------------------- Aturan 1
  /// kompatibel1(M, C) benar bila form factor papan induk termasuk himpunan
  /// form factor yang didukung casing.
  ConstraintResult periksaFormFactor(PcComponent mb, PcComponent? casing) {
    if (casing == null) return const ConstraintResult(CompatStatus.kompatibel);
    if (casing.formFactors.contains(mb.formFactor)) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
      ConstraintReason(
        kode: 'R1',
        pesan: 'Tidak muat di casing',
        terperinci: 'Papan induk berukuran ${mb.formFactor} tidak dapat dipasang '
            'pada ${casing.nama} yang hanya mendukung '
            '${casing.formFactors.join(", ")}.',
        saran: 'Pilih papan induk berukuran '
            '${casing.formFactors.join(" atau ")}, atau ganti casing.',
      ),
    ]);
  }

  // ---------------------------------------------------------------- Aturan 2
  /// kompatibel2(G, C) benar bila panjang kartu grafis tidak melebihi ruang
  /// bebas casing; status peringatan bila ruang sisa lebih kecil dari delta.
  ConstraintResult periksaPanjangGpu(PcComponent gpu, PcComponent? casing) {
    if (casing == null || casing.maxGpuLengthMm == null) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    final int batas = casing.maxGpuLengthMm!;
    final int panjang = gpu.lengthMm ?? 0;
    if (panjang > batas) {
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
        ConstraintReason(
          kode: 'R2',
          pesan: 'Kepanjangan! ($panjang mm > $batas mm)',
          terperinci: 'Kartu grafis ${gpu.nama} panjangnya $panjang mm, '
              'sedangkan ruang bebas ${casing.nama} hanya $batas mm.',
          saran: 'Pilih kartu grafis dengan panjang maksimal $batas mm.',
        ),
      ]);
    }
    final int ruang = batas - panjang;
    if (ruang < deltaMm) {
      return ConstraintResult(CompatStatus.peringatan, alasan: [
        ConstraintReason(
          kode: 'R2',
          pesan: 'Ruang tinggal $ruang mm',
          terperinci: 'Kartu grafis masih masuk, tetapi sisa ruang hanya $ruang mm '
              'sehingga penataan kabel akan rapat.',
          saran: 'Pertimbangkan kartu grafis yang sedikit lebih pendek.',
          fatal: false,
        ),
      ]);
    }
    return const ConstraintResult(CompatStatus.kompatibel);
  }

  // ---------------------------------------------------------------- Aturan 3
  /// kompatibel3(M, P) benar bila soket papan induk sama dengan soket prosesor.
  ConstraintResult periksaSoket(PcComponent mb, PcComponent? cpu) {
    if (cpu == null) return const ConstraintResult(CompatStatus.kompatibel);
    if (mb.socketType == cpu.socketType) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
      ConstraintReason(
        kode: 'R3',
        pesan: 'Soket beda',
        terperinci: 'Prosesor ${cpu.nama} memakai soket ${cpu.socketType}, '
            'sedangkan papan induk ini memakai ${mb.socketType}.',
        saran: 'Pilih papan induk bersoket ${cpu.socketType}.',
      ),
    ]);
  }

  /// kompatibel3(R, M) benar bila generasi memori sama dengan tipe memori
  /// yang didukung papan induk.
  ConstraintResult periksaTipeRam(PcComponent ram, PcComponent? mb) {
    if (mb == null) return const ConstraintResult(CompatStatus.kompatibel);
    if (ram.ramType == mb.ramType) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
      ConstraintReason(
        kode: 'R3',
        pesan: 'Generasi memori beda',
        terperinci: 'Modul ${ram.nama} bertipe ${ram.ramType}, sedangkan '
            'papan induk hanya mendukung ${mb.ramType}.',
        saran: 'Pilih modul ${mb.ramType}.',
      ),
    ]);
  }

  // ---------------------------------------------------------------- Aturan 4
  /// kompatibel4(K, P) benar bila kapasitas disipasi pendingin paling sedikit
  /// sama dengan TDP puncak prosesor; peringatan bila cadangan lebih kecil dari
  /// epsilon.
  ConstraintResult periksaTermal(PcComponent cooler, PcComponent? cpu) {
    if (cpu == null || cpu.peakTdpWatt == null || cooler.maxTdpWatt == null) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    final int puncak = cpu.peakTdpWatt!;
    final int kapasitas = cooler.maxTdpWatt!;
    if (kapasitas < puncak) {
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
        ConstraintReason(
          kode: 'R4',
          pesan: 'Risiko throttling!',
          terperinci: 'Pendingin ${cooler.nama} hanya mampu membuang '
              '$kapasitas W, sedangkan TDP puncak ${cpu.nama} mencapai $puncak W '
              'sehingga prosesor akan menurunkan kecepatan saat beban penuh.',
          saran: 'Pilih pendingin dengan kapasitas minimal $puncak W.',
        ),
      ]);
    }
    final double cadangan = kapasitas / puncak;
    if (cadangan < epsilon) {
      return ConstraintResult(CompatStatus.peringatan, alasan: [
        ConstraintReason(
          kode: 'R4',
          pesan: 'Cadangan termal tipis',
          terperinci: 'Kapasitas $kapasitas W hanya ${cadangan.toStringAsFixed(2)} kali '
              'TDP puncak $puncak W, sehingga pendingin bekerja mendekati batas.',
          saran: 'Pendingin dengan kapasitas di atas ${(puncak * epsilon).round()} W '
              'lebih aman untuk beban kerja panjang.',
          fatal: false,
        ),
      ]);
    }
    return const ConstraintResult(CompatStatus.kompatibel);
  }

  // ---------------------------------------------------------------- Aturan 5
  /// kompatibel5(K, C) bercabang: pendingin udara diperiksa tingginya,
  /// pendingin cairan diperiksa ukuran radiatornya.
  ConstraintResult periksaDimensiCooler(PcComponent cooler, PcComponent? casing) {
    if (casing == null) return const ConstraintResult(CompatStatus.kompatibel);
    if (cooler.coolerType == 'AIR') {
      if (casing.maxCoolerHeightMm == null || cooler.heightMm == null) {
        return const ConstraintResult(CompatStatus.kompatibel);
      }
      final int batas = casing.maxCoolerHeightMm!;
      final int tinggi = cooler.heightMm!;
      if (tinggi <= batas) return const ConstraintResult(CompatStatus.kompatibel);
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
        ConstraintReason(
          kode: 'R5',
          pesan: 'Terlalu tinggi ($tinggi mm > $batas mm)',
          terperinci: 'Tinggi menara ${cooler.nama} mencapai $tinggi mm, '
              'sedangkan ${casing.nama} hanya menerima setinggi $batas mm.',
          saran: 'Pilih pendingin udara dengan tinggi maksimal $batas mm.',
        ),
      ]);
    }
    final List<int> braket = casing.radiators;
    if (braket.isEmpty) {
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
        ConstraintReason(
          kode: 'R5',
          pesan: 'Tanpa braket radiator',
          terperinci: '${casing.nama} tidak menyediakan braket untuk pendingin cairan.',
          saran: 'Gunakan pendingin udara, atau pilih casing yang mendukung AIO.',
        ),
      ]);
    }
    final int? radiator = cooler.radiatorSize;
    if (radiator != null && braket.contains(radiator)) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
      ConstraintReason(
        kode: 'R5',
        pesan: 'Radiator tidak didukung',
        terperinci: 'Radiator ${radiator}mm tidak termasuk braket yang tersedia pada '
            '${casing.nama} (${braket.join(", ")} mm).',
        saran: 'Pilih radiator ${braket.join(" atau ")} mm.',
      ),
    ]);
  }

  // ---------------------------------------------------------------- Aturan 6
  /// daya_total = p(P) + g(G) + dasar.
  int dayaTotal({PcComponent? cpu, PcComponent? gpu}) =>
      (cpu?.peakTdpWatt ?? 0) + (gpu?.tdpWatt ?? 0) + dayaDasarWatt;

  /// rekomendasi = 130 x ceil(alpha x daya_total / 130).
  int rekomendasiPsu(int dayaTotal) =>
      130 * (alpha * dayaTotal / 130).ceil();

  /// Status catu daya: aman, peringatan, atau tidak layak.
  ConstraintResult periksaPsu(PcComponent psu, int dayaTotal, int rekomendasi) {
    final int kapasitas = psu.wattage ?? 0;
    if (kapasitas < dayaTotal) {
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
        ConstraintReason(
          kode: 'R6',
          pesan: 'Daya tidak cukup',
          terperinci: 'Kebutuhan daya sistem $dayaTotal W, sedangkan ${psu.nama} '
              'hanya menyediakan $kapasitas W sehingga sistem berisiko mati mendadak.',
          saran: 'Pilih catu daya minimal $rekomendasi W.',
        ),
      ]);
    }
    if (kapasitas < rekomendasi) {
      final int margin = ((kapasitas - dayaTotal) / dayaTotal * 100).round();
      return ConstraintResult(CompatStatus.peringatan, alasan: [
        ConstraintReason(
          kode: 'R6',
          pesan: 'Cadangan daya $margin%',
          terperinci: 'Kebutuhan $dayaTotal W masih tertutup, tetapi margin $margin% '
              'berada di bawah ambang aman 30%. Rekomendasi $rekomendasi W.',
          saran: 'Pilih catu daya minimal $rekomendasi W agar efisiensi tetap tinggi.',
          fatal: false,
        ),
      ]);
    }
    return const ConstraintResult(CompatStatus.kompatibel);
  }

  /// Status form factor catu daya terhadap casing.
  ConstraintResult periksaPsuFormFactor(PcComponent psu, PcComponent? casing) {
    if (casing == null) return const ConstraintResult(CompatStatus.kompatibel);
    if (psu.psuFormFactor == casing.psuFormFactor) {
      return const ConstraintResult(CompatStatus.kompatibel);
    }
    return ConstraintResult(CompatStatus.tidakKompatibel, alasan: [
      ConstraintReason(
        kode: 'R6',
        pesan: 'Ukuran catu daya beda',
        terperinci: '${casing.nama} memerlukan catu daya berukuran '
            '${casing.psuFormFactor}, sedangkan komponen ini ${psu.psuFormFactor}.',
        saran: 'Pilih catu daya berukuran ${casing.psuFormFactor}.',
      ),
    ]);
  }

  // ---------------------------------------------------------------- gabungan
  /// Menjalankan seluruh aturan yang berlaku bagi satu komponen kandidat.
  ConstraintResult periksa(PcComponent kandidat, BuildConfig config) {
    final a = <ConstraintReason>[];

    switch (kandidat.type) {
      case ComponentType.motherboard:
        a.addAll(periksaFormFactor(kandidat, config.casing).alasan);
        a.addAll(periksaSoket(kandidat, config.cpu).alasan);
      case ComponentType.gpu:
        a.addAll(periksaPanjangGpu(kandidat, config.casing).alasan);
      case ComponentType.cooler:
        a.addAll(periksaTermal(kandidat, config.cpu).alasan);
        a.addAll(periksaDimensiCooler(kandidat, config.casing).alasan);
      case ComponentType.ram:
        a.addAll(periksaTipeRam(kandidat, config.motherboard).alasan);
      case ComponentType.psu:
        a.addAll(periksaPsu(
          kandidat,
          dayaTotal(cpu: config.cpu, gpu: config.gpu),
          rekomendasiPsu(dayaTotal(cpu: config.cpu, gpu: config.gpu)),
        ).alasan);
        a.addAll(periksaPsuFormFactor(kandidat, config.casing).alasan);
      case ComponentType.casing:
      case ComponentType.cpu:
      case ComponentType.storage:
        break;
    }

    // Alasan fatal diperiksa lebih dahulu, bahkan untuk komponen yang sedang
    // terpilih. Tanpa urutan ini, pergantian komponen hulu tidak akan pernah
    // memicu auto-reset karena komponen hilir selalu berstatus terpilih.
    if (a.any((r) => r.fatal)) {
      return ConstraintResult(CompatStatus.tidakKompatibel, alasan: a);
    }
    if (config.slot(kandidat.type)?.id == kandidat.id) {
      return ConstraintResult(CompatStatus.terpilih, alasan: a);
    }
    if (a.isNotEmpty) {
      return ConstraintResult(CompatStatus.peringatan, alasan: a);
    }
    return const ConstraintResult(CompatStatus.kompatibel);
  }

  // ---------------------------------------------------------------- Aturan 7
  /// reset(C_baru, P_baru): mengosongkan slot hilir yang menjadi tidak
  /// kompatibel setelah komponen hulu berubah. Seluruh slot hilir divalidasi
  /// ulang satu per satu mengikuti arah ketergantungan, sehingga tidak perlu
  /// mengetahui slot hulu mana yang berubah. Mengembalikan daftar pesan
  /// notifikasi untuk ditampilkan sebagai SnackBar.
  List<({ComponentType slot, String pesan})> resolusiKonflik(BuildConfig config) {
    final hasil = <({ComponentType slot, String pesan})>[];
    final urutan = <ComponentType>[
      ComponentType.motherboard,
      ComponentType.ram,
      ComponentType.gpu,
      ComponentType.cooler,
      ComponentType.psu,
    ];

    var kerja = config;
    for (final slot in urutan) {
      final terpilih = kerja.slot(slot);
      if (terpilih == null) continue;
      final hasil1 = periksa(terpilih, kerja);
      if (hasil1.status != CompatStatus.tidakKompatibel) continue;
      final alasan = hasil1.alasanUtama;
      final String sebab = alasan?.pesan ?? 'tidak lagi kompatibel';
      hasil.add((
        slot: slot,
        pesan: '${slot.label} direset: $sebab',
      ));
      kerja = switch (slot) {
        ComponentType.motherboard => kerja.copyWith(hapusMotherboard: true),
        ComponentType.gpu => kerja.copyWith(hapusGpu: true),
        ComponentType.cooler => kerja.copyWith(hapusCooler: true),
        ComponentType.psu => kerja.copyWith(hapusPsu: true),
        ComponentType.ram => kerja.copyWith(ram: const []),
        _ => kerja,
      };
    }
    return hasil;
  }
}
