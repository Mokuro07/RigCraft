import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/prebuilt_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/rigcare_screen.dart';
import '../utils/app_colors.dart';

/// HomeScreen: kerangka utama dengan NavigationBar empat tab (sub-bab 3.8.1).
/// Hanya berisi rangka dan navigasi; isi tiap tab ada di berkas screen masing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const List<({String label, IconData ikon, IconData ikonAktif})> _tabInfo = [
    (label: 'Smart Builder', ikon: Icons.build_outlined, ikonAktif: Icons.build),
    (label: 'Pre-Built', ikon: Icons.auto_awesome_outlined, ikonAktif: Icons.auto_awesome),
    (
      label: 'RigCare+',
      ikon: Icons.health_and_safety_outlined,
      ikonAktif: Icons.health_and_safety
    ),
    (label: 'Profil', ikon: Icons.person_outline, ikonAktif: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Row(
          children: [
            Icon(Icons.memory, color: AppColors.selected, size: 22),
            SizedBox(width: 8),
            Text('RigCraft',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          DashboardScreen(),
          PrebuiltScreen(),
          RigCareScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.selected.withValues(alpha: 0.22),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final t in _tabInfo)
            NavigationDestination(
              icon: Icon(t.ikon, color: AppColors.textSecondary, size: 22),
              selectedIcon: Icon(t.ikonAktif, color: AppColors.selected, size: 22),
              label: t.label,
            ),
        ],
      ),
    );
  }
}
