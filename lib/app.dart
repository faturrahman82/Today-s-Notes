import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reflection/reflection_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/journal_controller.dart';
import 'services/settings_controller.dart';

class JurnalApp extends StatefulWidget {
  const JurnalApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<JurnalApp> createState() => _JurnalAppState();
}

class _JurnalAppState extends State<JurnalApp> {
  late final JournalController journalController;
  late final SettingsController settingsController;

  @override
  void initState() {
    super.initState();
    journalController = JournalController(widget.preferences);
    settingsController = SettingsController(widget.preferences);
  }

  @override
  void dispose() {
    journalController.dispose();
    settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) => MaterialApp(
        title: 'Jurnal Hari Ini',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildDarkAppTheme(),
        themeMode: settingsController.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        home: settingsController.hasSeenOnboarding
            ? JurnalShell(
                controller: journalController,
                settings: settingsController,
              )
            : OnboardingScreen(
                onDone: () {
                  settingsController.completeOnboarding();
                },
              ),
      ),
    );
  }
}

class JurnalShell extends StatefulWidget {
  const JurnalShell({
    super.key,
    required this.controller,
    required this.settings,
  });

  final JournalController controller;
  final SettingsController settings;

  @override
  State<JurnalShell> createState() => _JurnalShellState();
}

class _JurnalShellState extends State<JurnalShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: moss)),
          );
        }

        final pages = [
          HomeScreen(
            controller: widget.controller,
            onOpenSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(
                    controller: widget.controller,
                    settings: widget.settings,
                  ),
                ),
              );
            },
          ),
          HistoryScreen(
            controller: widget.controller,
            onGoHome: () => setState(() => selectedIndex = 0),
          ),
          ReflectionScreen(controller: widget.controller),
        ];

        return Scaffold(
          body: SafeArea(child: pages[selectedIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: 'Hari ini',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Riwayat',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Refleksi',
              ),
            ],
          ),
        );
      },
    );
  }
}
