import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/data/component_repository.dart';
import 'package:flutter_application_2/models/build_config.dart';
import 'package:flutter_application_2/models/constraint_result.dart';
import 'package:flutter_application_2/models/pc_component.dart';
import 'package:flutter_application_2/providers/configurator_provider.dart';
import 'package:flutter_application_2/services/constraint_engine.dart';
import 'package:flutter_application_2/services/price_calculator.dart';
import 'package:flutter_application_2/services/thermal_analyzer.dart';

/// Uji tujuh aturan Constraint Engine terhadap data seed.
/// Setiap grup memetakan langsung ke skenario Black-Box pada Tabel 3.34.
void main() {
  const e = ConstraintEngine();
  final repo = ComponentRepository();

  PcComponent c(String id) {
    final PcComponent? k = repo.byId(id);
    if (k == null) throw StateError('komponen $id tidak ada pada seed');
    return k;
  }

  group('katalog seed', () {
    test('memuat 24 komponen, tiga per jenis', () {
      for (final t in ComponentType.values) {
        expect(repo.byType(t).length, 3, reason: 'jenis ${t.label}');
      }
      expect(repo.semua.length, 24);
    });

    test('kolom spesifik hanya terisi pada jenis yang memilikinya', () {
      expect(c('cs-01').supportedFormFactors, isNotNull);
      expect(c('cs-01').socketType, isNull);
      expect(c('cpu-01').supportedFormFactors, isNull);
      expect(c('cl-01').radiatorSize, isNull, reason: 'pendingin udara');
      expect(c('cl-03').heightMm, isNull, reason: 'pendingin cairan');
    });
  });

  group('BB-02 Aturan 1 form factor casing dan motherboard', () {
    test('casing ITX menolak papan induk ATX', () {
      final r = e.periksaFormFactor(c('mb-01'), c('cs-03'));
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Tidak muat di casing');
      expect(r.alasanUtama!.saran, contains('ITX'));
    });

    test('casing ITX menolak papan induk MATX', () {
      expect(e.periksaFormFactor(c('mb-03'), c('cs-03')).status,
          CompatStatus.tidakKompatibel);
    });

    test('casing ATX menerima MATX', () {
      expect(e.periksaFormFactor(c('mb-03'), c('cs-01')).status,
          CompatStatus.kompatibel);
    });
  });

  group('BB-03 Aturan 2 panjang kartu grafis terhadap ruang casing', () {
    test('348 mm ditolak oleh ruang bebas 322 mm', () {
      final r = e.periksaPanjangGpu(c('gpu-02'), c('cs-01'));
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Kepanjangan! (348 mm > 322 mm)');
    });

    test('305 mm lolos dengan ruang sisa 17 mm', () {
      expect(e.periksaPanjangGpu(c('gpu-01'), c('cs-01')).status,
          CompatStatus.kompatibel);
    });

    test('ruang sisa di bawah ambang 15 mm menghasilkan peringatan', () {
      const gpu = PcComponent(
          type: ComponentType.gpu, id: 'uji', nama: 'Uji', harga: 0, lengthMm: 312);
      final r = e.periksaPanjangGpu(gpu, c('cs-01'));
      expect(r.status, CompatStatus.peringatan);
      expect(r.alasanUtama!.pesan, 'Ruang tinggal 10 mm');
    });
  });

  group('BB-04 Aturan 3 soket dan tipe memori', () {
    test('soket AM5 ditolak papan induk LGA1700', () {
      final r = e.periksaSoket(c('mb-03'), c('cpu-01'));
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Soket beda');
    });

    test('soket AM5 diterima papan induk AM5', () {
      expect(e.periksaSoket(c('mb-01'), c('cpu-01')).status,
          CompatStatus.kompatibel);
    });

    test('memori DDR4 tersaring dari papan induk DDR5', () {
      expect(e.periksaTipeRam(c('ram-03'), c('mb-01')).status,
          CompatStatus.tidakKompatibel);
      expect(e.periksaTipeRam(c('ram-01'), c('mb-01')).status,
          CompatStatus.kompatibel);
    });
  });

  group('BB-05 Aturan 4 dan 5 kapasitas termal serta dimensi pendingin', () {
    test('pendingin 180 W ditolak TDP puncak 253 W', () {
      final r = e.periksaTermal(c('cl-01'), c('cpu-02'));
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Risiko throttling!');
      expect(r.alasanUtama!.saran, contains('253 W'));
    });

    test('pendingin 245 W ditolak TDP puncak 253 W', () {
      final r = e.periksaTermal(c('cl-02'), c('cpu-02'));
      expect(r.status, CompatStatus.tidakKompatibel, reason: '245 W < 253 W');
    });

    test('cadangan termal tipis menghasilkan peringatan', () {
      // Ambang epsilon = 1,15. TDP puncak 253 W memerlukan kapasitas minimal
      // 291 W agar tidak berperingatan, sehingga pendingin 300 W dinyatakan
      // kompatibel dan kasus peringatan diuji memakai TDP 265 W.
      const cpu265 = PcComponent(
          type: ComponentType.cpu, id: 'uji', nama: 'Uji 265 W', harga: 0,
          socketType: 'AM5', peakTdpWatt: 265);
      final r = e.periksaTermal(c('cl-03'), cpu265);
      expect(r.status, CompatStatus.peringatan, reason: '300/265 = 1,13 < 1,15');
      expect(r.alasanUtama!.fatal, isFalse);
    });

    test('pendingin 300 W untuk TDP 170 W dinyatakan kompatibel', () {
      expect(e.periksaTermal(c('cl-03'), c('cpu-03')).status,
          CompatStatus.kompatibel);
    });

    test('radiator 360 mm ditolak casing yang hanya mendukung 120 dan 240 mm', () {
      final r = e.periksaDimensiCooler(c('cl-03'), c('cs-03'));
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Radiator tidak didukung');
    });

    test('pendingin udara setinggi 155 mm lolos pada batas 155 mm', () {
      expect(e.periksaDimensiCooler(c('cl-01'), c('cs-03')).status,
          CompatStatus.kompatibel);
    });

    test('casing tanpa braket menolak pendingin cairan', () {
      const tanpaBraket = PcComponent(
          type: ComponentType.casing, id: 'uji', nama: 'Uji', harga: 0,
          supportedFormFactors: 'ATX', maxGpuLengthMm: 300,
          maxCoolerHeightMm: 160, psuFormFactor: 'ATX');
      final r = e.periksaDimensiCooler(c('cl-03'), tanpaBraket);
      expect(r.status, CompatStatus.tidakKompatibel);
      expect(r.alasanUtama!.pesan, 'Tanpa braket radiator');
    });
  });

  group('BB-06 Aturan 6 daya, rekomendasi PSU, dan anggaran', () {
    test('daya total 170 + 285 + 80 = 535 W', () {
      expect(e.dayaTotal(cpu: c('cpu-03'), gpu: c('gpu-01')), 535);
    });

    test('rekomendasi PSU 130 x ceil(1,3 x 535 / 130) = 780 W', () {
      expect(e.rekomendasiPsu(535), 780);
    });

    test('catu daya 750 W berstatus peringatan terhadap kebutuhan 535 W', () {
      final r = e.periksaPsu(c('psu-01'), 535, 780);
      expect(r.status, CompatStatus.peringatan);
      expect(r.alasanUtama!.pesan, 'Cadangan daya 40%');
    });

    test('catu daya 800 W dinyatakan kompatibel', () {
      expect(e.periksaPsu(c('psu-02'), 535, 780).status, CompatStatus.kompatibel);
    });

    test('catu daya 650 W berstatus peringatan bila kebutuhan 535 W', () {
      final r = e.periksaPsu(c('psu-03'), 535, 780);
      expect(r.status, CompatStatus.peringatan, reason: '535 <= 650 < 780');
    });

    test('catu daya 650 W tidak layak bila kebutuhan 700 W', () {
      final r = e.periksaPsu(c('psu-03'), 700, 910);
      expect(r.status, CompatStatus.tidakKompatibel, reason: '650 < 700');
    });

    test('ukuran catu daya wajib mengikuti casing', () {
      expect(e.periksaPsuFormFactor(c('psu-03'), c('cs-03')).status,
          CompatStatus.kompatibel, reason: 'SFX dengan SFX');
      expect(e.periksaPsuFormFactor(c('psu-01'), c('cs-03')).status,
          CompatStatus.tidakKompatibel, reason: 'ATX tidak muat casing SFX');
    });

    group('kalkulasi harga dan anggaran', () {
      const p = PriceCalculator();
      test('total harga menjumlahkan seluruh komponen terpilih', () {
        final config = BuildConfig(
          casing: c('cs-03'), cpu: c('cpu-03'), motherboard: c('mb-03'),
          gpu: c('gpu-03'), cooler: c('cl-01'), ram: [c('ram-03')],
          storage: [c('st-02')], psu: c('psu-03'),
        );
        final int manual = 1549000 + 6900000 + 1650000 + 4700000 + 480000 +
            520000 + 650000 + 1200000;
        expect(p.totalHarga(config), manual);
        expect(config.lengkap, isTrue);
        expect(config.progres, 100);
      });

      test('pemantauan batas anggaran', () {
        final config = BuildConfig(
          budget: 1000000, casing: c('cs-01'), cpu: c('cpu-01'));
        expect(p.melebihiAnggaran(config), isTrue);
        expect(p.selisihAnggaran(config), 1000000 - (1299000 + 2850000));
      });
    });

    test('analisis termal memberi label sesuai rasio cadangan', () {
      const t = ThermalAnalyzer();
      expect(t.statusTermal(BuildConfig(cpu: c('cpu-02'), cooler: c('cl-01'))),
          'Risiko throttling');
      expect(t.statusTermal(BuildConfig()), 'Belum lengkap');
      expect(t.statusTermal(BuildConfig(cpu: c('cpu-03'), cooler: c('cl-02'))), 'Aman',
          reason: '245/170 = 1,44');
      expect(t.statusTermal(BuildConfig(cpu: c('cpu-01'), cooler: c('cl-02'))),
          'Sangat lega', reason: '245/88 = 2,78');
    });
  });

  group('BB-07 Aturan 7 resolusi konflik otomatis', () {
    test('papan induk ATX direset ketika casing diganti ke ITX', () {
      final config = BuildConfig(
        casing: c('cs-03'), cpu: c('cpu-01'), motherboard: c('mb-01'));
      final r = e.resolusiKonflik(config);
      expect(r.length, 1);
      expect(r.first.slot, ComponentType.motherboard);
      expect(r.first.pesan, contains('Motherboard direset'));
    });

    test('tidak ada reset bila seluruh komponen tetap kompatibel', () {
      final config = BuildConfig(
        casing: c('cs-01'), cpu: c('cpu-01'), motherboard: c('mb-01'));
      expect(e.resolusiKonflik(config), isEmpty);
    });

    test('memori ikut direset bila tipe memori papan induk berubah', () {
      // Papan induk DDR5 diganti menjadi papan induk DDR4: modul DDR5 menjadi konflik.
      final config = BuildConfig(motherboard: c('mb-03'), ram: [c('ram-01')]);
      final r = e.resolusiKonflik(config);
      expect(r.map((x) => x.slot), contains(ComponentType.ram));
      expect(r.first.pesan, contains('Memori direset'));
    });
  });

  group('BB-08 ConfiguratorProvider penyimpanan dan riwayat', () {
    test('rakitan belum lengkap ditolak saat disimpan', () {
      final p = ConfiguratorProvider();
      expect(p.simpan('Belum Lengkap'), isFalse);
      expect(p.notifikasi, contains('belum lengkap'));
      expect(p.riwayat, isEmpty);
    });

    test('rakitan lengkap tersimpan beserta nilai turunan', () {
      final p = ConfiguratorProvider();
      for (final k in [
        c('cs-01'), c('cpu-01'), c('mb-01'), c('gpu-01'),
        c('cl-02'), c('ram-01'), c('st-01'), c('psu-01'),
      ]) {
        p.pilih(k);
      }
      expect(p.config.lengkap, isTrue, reason: 'seluruh slot wajib terisi');
      expect(p.simpan('Rakitan Uji'), isTrue);
      expect(p.riwayat.length, 1);
      final b = p.riwayat.first;
      expect(b.totalHarga, p.totalHarga);
      expect(b.totalDayaWatt, 88 + 285 + 80);
      expect(b.rekomendasiPsuWatt, 130 * (1.3 * (88 + 285 + 80) / 130).ceil());
      expect(b.nama, 'Rakitan Uji');
    });

    test('penggantian casing memicu auto-reset papan induk', () {
      final p = ConfiguratorProvider();
      p.pilih(c('cs-01'));
      p.pilih(c('cpu-01'));
      p.pilih(c('mb-01'));
      expect(p.config.motherboard!.id, 'mb-01');
      p.pilih(c('cs-03'));
      expect(p.config.motherboard, isNull, reason: 'ATX tidak muat di casing ITX');
      expect(p.notifikasi, contains('Motherboard direset'));
    });

    test('komponen tidak kompatibel tidak dapat dipilih', () {
      final p = ConfiguratorProvider();
      p.pilih(c('cs-03'));
      p.pilih(c('mb-01'));
      expect(p.config.motherboard, isNull);
      expect(p.notifikasi, 'Tidak muat di casing');
    });

    test('pergantian mode menyusun ulang urutan langkah', () {
      final p = ConfiguratorProvider();
      expect(p.tipeSaatIni, ComponentType.casing);
      p.gantiMode(BuildMode.cpuFirst);
      expect(p.tipeSaatIni, ComponentType.cpu);
      expect(p.config.mode, BuildMode.cpuFirst);
    });
  });
}
