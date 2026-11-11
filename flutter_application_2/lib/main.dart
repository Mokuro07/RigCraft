import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'providers/configurator_provider.dart';
import 'utils/app_colors.dart';

/// Titik masuk aplikasi RigCraft.
///
/// ConfiguratorProvider menjadi satu sumber kebenaran seluruh pilihan rakitan;
/// Constraint Engine memvalidasi setiap komponen yang dipilih, PriceCalculator
/// menghitung biaya, dan ThermalAnalyzer menilai keseimbangan termal.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConfiguratorProvider(),
      child: const RigCraftApp(),
    ),
  );
}

class RigCraftApp extends StatelessWidget {
  const RigCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RigCraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.selected,
          brightness: Brightness.dark,
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 12.5),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
