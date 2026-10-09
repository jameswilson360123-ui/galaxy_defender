import 'package:flutter/material.dart';
import 'package:galaxy_defender/app/app_routes.dart';
import 'package:galaxy_defender/data/game_save.dart';
import 'package:galaxy_defender/screens/gameplay_screen.dart';
import 'package:galaxy_defender/screens/hangar_screen.dart';
import 'package:galaxy_defender/screens/main_menu_screen.dart';
import 'package:galaxy_defender/screens/settings_screen.dart';
import 'package:galaxy_defender/screens/upgrade_screen.dart';

class GalaxyDefenderApp extends StatelessWidget {
  const GalaxyDefenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galaxy Defender',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A5CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF050914),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      initialRoute: AppRoutes.mainMenu,
      routes: {
        AppRoutes.mainMenu: (_) => const MainMenuScreen(),
        AppRoutes.hangar: (_) => const HangarScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.upgrades: (_) => const UpgradeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.gameplay) {
          final save = settings.arguments is GameSave ? settings.arguments as GameSave : GameSave.initial();
          return MaterialPageRoute(
            builder: (_) => GameplayScreen(save: save),
          );
        }
        return null;
      },
    );
  }
}
