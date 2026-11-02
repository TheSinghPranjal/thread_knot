import 'package:flutter/material.dart';

import 'persist/progress.dart';
import 'theme/app_theme.dart';
import 'ui/daily_screen.dart';
import 'ui/home_screen.dart';
import 'ui/me_screen.dart';
import 'ui/splash_screen.dart';

class ThreadKnotApp extends StatelessWidget {
  const ThreadKnotApp({super.key, required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thread Knot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: SplashScreen(next: (_) => AppShell(progress: progress)),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.progress});

  final ProgressStore progress;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(progress: widget.progress),
      DailyScreen(progress: widget.progress),
      MeScreen(progress: widget.progress),
    ];
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.ink.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Play',
            ),
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded),
              label: 'Daily',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
