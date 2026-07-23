import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/coach/coach_screen.dart';
import '../features/workout/workout_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/logging/logging_sheet.dart';

class NutriLocalApp extends ConsumerStatefulWidget {
  const NutriLocalApp({super.key});

  @override
  ConsumerState<NutriLocalApp> createState() => _NutriLocalAppState();
}

class _NutriLocalAppState extends ConsumerState<NutriLocalApp> {
  bool _isOnboardingComplete = true; // Default ready
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriLocal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: !_isOnboardingComplete
          ? OnboardingScreen(
              onComplete: () => setState(() => _isOnboardingComplete = true),
            )
          : Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  DashboardScreen(onOpenLogging: _openLoggingSheet),
                  const DiaryScreen(),
                  const CoachScreen(),
                  const WorkoutScreen(),
                  const ProgressScreen(),
                  const SettingsScreen(),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Heute'),
                  NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Tagebuch'),
                  NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Coach'),
                  NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Workout'),
                  NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Trends'),
                  NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Optionen'),
                ],
              ),
            ),
    );
  }

  void _openLoggingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LoggingSheet(),
    );
  }
}
