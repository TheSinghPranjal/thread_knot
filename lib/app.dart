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
      // Let each tab's backdrop run behind the floating nav bar.
      extendBody: true,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: _FloatingNavBar(
        index: _tab,
        onSelect: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final Widget Function(Color color) icon;
}

/// Rounded, floating cream bar; the active tab becomes a glossy red pill.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static final _items = [
    _NavItem('Play', (c) => Icon(Icons.home_rounded, color: c, size: 30)),
    _NavItem('Daily', (c) => _DailyIcon(color: c)),
    _NavItem(
      'Me',
      (c) => Icon(Icons.person_outline_rounded, color: c, size: 30),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < _items.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 1.5,
            height: 34,
            color: const Color(0xFFE9D3C6),
          ),
        );
      }
      children.add(
        Expanded(
          child: _NavButton(
            item: _items[i],
            selected: i == index,
            onTap: () => onSelect(i),
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: Container(
          height: 78,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFCF9), Color(0xFFFBEDE4)],
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC07A5C).withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _idle = Color(0xFF5B3A8C);

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : _idle;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF7E6B), Color(0xFFE9473A)],
                  )
                : null,
            border: selected
                ? Border.all(color: const Color(0xFFFFB3A6), width: 1.5)
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFE9473A).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.icon(color),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Calendar with a gold star, matching the daily challenge artwork.
class _DailyIcon extends StatelessWidget {
  const _DailyIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, color: color, size: 28),
          const Positioned(
            top: 11,
            child: Icon(Icons.star_rounded, color: AppTheme.gold, size: 15),
          ),
        ],
      ),
    );
  }
}
