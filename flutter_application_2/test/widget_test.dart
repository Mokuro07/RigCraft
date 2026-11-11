// Uji asap (smoke test) untuk aplikasi RigCraft.
// Memeriksa bahwa tiap layar terbangun, navigasi tab bekerja, halaman perakitan
// terbuka dari tombol (+), dan pemilihan komponen mengubah keadaan.
//
// Catatan: bagian dasbor yang panjang berada di bawah viewport uji bawaan
// (800x600), jadi ukuran layar disetel ke ukuran ponsel lebih dahulu dan
// bagian yang jauh dari atas digulir sebelum diperiksa.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/models/pc_component.dart';
import 'package:flutter_application_2/providers/configurator_provider.dart';
import 'package:flutter_application_2/screens/builder_screen.dart';

Widget berbalut(ConfiguratorProvider p) => ChangeNotifierProvider.value(
      value: p,
      child: const RigCraftApp(),
    );

/// Menyetel ukuran layar uji menyerupai ponsel.
Future<void> aturLayarPonsel(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Menggulir layar sampai teks tujuan terlihat.
Future<void> gulirKe(WidgetTester tester, Finder target) => tester.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );

void main() {
  testWidgets('dasbor menampilkan ringkasan, kategori, dan keadaan kosong',
      (tester) async {
    await aturLayarPonsel(tester);
    await tester.pumpWidget(berbalut(ConfiguratorProvider()));

    expect(find.text('RigCraft'), findsOneWidget);
    expect(find.text('Selamat datang di RigCraft'), findsOneWidget);
    expect(find.text('Kategori beban kerja'), findsOneWidget);
    expect(find.text('Gaming AAA'), findsOneWidget);
    expect(find.text('Komponen terpilih'), findsOneWidget);
    expect(find.textContaining('Belum ada komponen yang dipilih'), findsOneWidget);
    expect(find.text('Susun rakitan'), findsOneWidget);
  });

  testWidgets('tombol (+) membuka halaman perakitan', (tester) async {
    await aturLayarPonsel(tester);
    await tester.pumpWidget(berbalut(ConfiguratorProvider()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(BuilderScreen), findsOneWidget);
    expect(find.text('Perakitan'), findsOneWidget);
    expect(find.text('Anggaran & langkah'), findsOneWidget);
  });

  testWidgets('kartu sambutan membuka halaman perakitan', (tester) async {
    await aturLayarPonsel(tester);
    await tester.pumpWidget(berbalut(ConfiguratorProvider()));

    await tester.tap(find.text('Mulai menyusun rakitan'));
    await tester.pumpAndSettle();

    expect(find.byType(BuilderScreen), findsOneWidget);
    expect(find.text('1. Casing'), findsOneWidget);
  });

  testWidgets('memilih casing di perakitan mengisi slot dan memajukan langkah',
      (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final casing = p.kandidat(p.langkahAktif[0]).first;
    p.pilih(casing);
    await tester.pumpAndSettle();

    expect(p.config.jumlahTerpilih, 1);
    expect(p.totalHarga, casing.harga);
    expect(find.text('Total rakitan'), findsOneWidget);
  });

  testWidgets('bilah ringkasan memperbarui total setelah memilih', (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    p.pilih(p.kandidat(p.langkahAktif[0]).first);
    await tester.pumpAndSettle();

    expect(find.text('Rp 1.299.000'), findsOneWidget);
  });

  testWidgets('hasil pilihan muncul kembali di dasbor setelah kembali',
      (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    await tester.tap(find.text('Mulai menyusun rakitan'));
    await tester.pumpAndSettle();
    p.pilih(p.kandidat(p.langkahAktif[0]).first);
    await tester.pumpAndSettle();

    // Kembali ke dasbor memakai tombol kembali pada AppBar.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(BuilderScreen), findsNothing);
    expect(find.text('Komponen terpilih'), findsOneWidget);
    await gulirKe(tester, find.text('NZXT H5 Flow'));
    expect(find.text('NZXT H5 Flow'), findsOneWidget);
    expect(find.text('Lanjut menyusun'), findsOneWidget);
    expect(find.textContaining('Progres rakitan'), findsOneWidget);
  });

  testWidgets('berpindah ke Mode Kebutuhan mengubah langkah pertama', (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mode Kebutuhan'));
    await tester.pumpAndSettle();

    expect(p.langkahAktif.first, ComponentType.cpu);
    expect(find.text('1. Prosesor'), findsOneWidget);
  });

  testWidgets('tab Pre-Built menyusun rakitan otomatis', (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    await tester.tap(find.byIcon(Icons.auto_awesome_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gaming AAA').last);
    await tester.pumpAndSettle();

    expect(p.config.kategoriId, 'GAMING');
    expect(p.config.semuaKomponen.isNotEmpty, true);

    await gulirKe(tester, find.textContaining('Total Rp'));
    expect(find.text('Rakitan hasil rekomendasi'), findsOneWidget);
  });

  testWidgets('tab RigCare+ menampilkan paket dan tombol pesan', (tester) async {
    await aturLayarPonsel(tester);
    await tester.pumpWidget(berbalut(ConfiguratorProvider()));

    await tester.tap(find.byIcon(Icons.health_and_safety_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Bersih Debu Standar'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('Pesan'), findsWidgets);
  });

  testWidgets('tab Profil menampilkan keadaan kosong sebelum ada rakitan',
      (tester) async {
    await aturLayarPonsel(tester);
    await tester.pumpWidget(berbalut(ConfiguratorProvider()));

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('Pengguna RigCraft'), findsOneWidget);
    expect(find.textContaining('Belum ada rakitan tersimpan'), findsOneWidget);
  });

  testWidgets('rakitan lengkap tersimpan dan muncul pada riwayat', (tester) async {
    await aturLayarPonsel(tester);
    final p = ConfiguratorProvider();
    await tester.pumpWidget(berbalut(p));

    for (var i = 0; i < p.langkahAktif.length; i++) {
      p.keLangkah(i);
      for (final k in p.kandidat(p.tipeSaatIni)) {
        if (p.status(k).bolehDipilih) {
          p.pilih(k);
          break;
        }
      }
    }
    expect(p.config.lengkap, true);

    expect(p.simpan('Rakitan Uji'), true);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('Rakitan Uji'), findsOneWidget);
    expect(find.text('Muat ke konfigurator'), findsOneWidget);
  });
}
