import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/configurator_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/section_header.dart';

/// ProfileScreen: halaman profil dan riwayat rakitan tersimpan (UC-11).
/// Daftar riwayat berasal dari repositori; memuat satu rakitan akan
/// mengembalikannya ke konfigurator Smart Builder.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConfiguratorProvider>();
    final riwayat = p.riwayat;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          judul: 'Profil & Riwayat',
          keterangan: '${riwayat.length} rakitan tersimpan pada penyimpanan lokal',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceAlt,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengguna RigCraft',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Data tersimpan lokal di perangkat ini',
                        style:
                            TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (riwayat.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24, left: 24, right: 24),
            child: Text(
              'Belum ada rakitan tersimpan.\nLengkapi rakitan di Smart Builder lalu '
              'tekan Simpan pada ringkasan rakitan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          )
        else
          for (final b in riwayat) ...[
            Card(
              color: AppColors.surface,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.nama,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${b.config.mode.label}  •  ${Fmt.rupiah(b.totalHarga)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Text(
                        'Daya ${b.totalDayaWatt} W  •  PSU ${b.rekomendasiPsuWatt} W  •  '
                        '${b.config.jumlahTerpilih} komponen',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          p.muatRakitan(b.config);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text('${b.nama} dimuat ke konfigurator.'),
                              backgroundColor: AppColors.surfaceAlt,
                              behavior: SnackBarBehavior.floating,
                            ));
                        },
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Muat ke konfigurator'),
                        style:
                            TextButton.styleFrom(foregroundColor: AppColors.selected),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
