import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/level_def.dart';
import '../../render/board_layout.dart';
import '../../render/board_painter.dart';
import '../../theme/app_theme.dart';
import '../widgets/decor.dart';

class CompleteOverlay extends StatefulWidget {
  const CompleteOverlay({
    super.key,
    required this.level,
    required this.onNext,
    required this.onMain,
    this.nextLabel = 'Next Game',
  });

  /// The level just solved, shown in its starting layout.
  final LevelDef level;
  final VoidCallback onNext;
  final VoidCallback onMain;
  final String nextLabel;

  @override
  State<CompleteOverlay> createState() => _CompleteOverlayState();
}

class _CompleteOverlayState extends State<CompleteOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b, [Curve c = Curves.easeOutBack]) =>
      CurvedAnimation(parent: _ctrl, curve: Interval(a, b, curve: c));

  @override
  Widget build(BuildContext context) {
    final title = _interval(0.0, 0.3);
    final ribbon = _interval(0.12, 0.38);
    final card = _interval(0.18, 0.5);
    final check = _interval(0.42, 0.62, Curves.elasticOut);
    final buttons = _interval(0.45, 0.7, Curves.easeOutCubic);

    return Material(
      color: const Color(0xFFFA8571),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => CustomPaint(
                painter: _SunburstPainter(progress: _ctrl.value),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(progress: _ctrl.value),
                ),
              ),
            ),
          ),
          const Positioned(
            left: -70,
            bottom: -70,
            child: YarnBall(size: 170, color: Color(0xFFF0675A), angle: 0.4),
          ),
          const Positioned(
            left: -40,
            bottom: 50,
            child: YarnBall(size: 110, color: Color(0xFF22C3BA), angle: 1.1),
          ),
          const Positioned(
            right: -60,
            bottom: -60,
            child: YarnBall(size: 170, color: Color(0xFFF7B52C), angle: -0.6),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ScaleTransition(scale: title, child: const _Headline()),
                  const SizedBox(height: 10),
                  ScaleTransition(
                    scale: ribbon,
                    child: const FittedBox(child: _Ribbon()),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: ScaleTransition(
                        scale: card,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _SolvedCard(level: widget.level, check: check),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: buttons,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(buttons),
                      child: Column(
                        children: [
                          _NextButton(
                            label: widget.nextLabel,
                            onTap: widget.onNext,
                          ),
                          const SizedBox(height: 14),
                          _MainLink(onTap: widget.onMain),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Path / Cleared!" with chunky purple outlines.
class _Headline extends StatelessWidget {
  const _Headline();

  static const _purple = Color(0xFF6B1F6E);

  Widget _outlined(String text, double size, List<Color> fill) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1.0,
      letterSpacing: -1,
    );
    return Stack(
      children: [
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.22
              ..strokeJoin = StrokeJoin.round
              ..color = _purple,
            shadows: [
              Shadow(
                color: const Color(0xFF8A2C3A).withValues(alpha: 0.45),
                offset: const Offset(0, 5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: fill,
              ).createShader(Rect.fromLTWH(0, 0, 0, size)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          _outlined('Path', 50, const [Colors.white, Color(0xFFF4E4FF)]),
          const SizedBox(height: 2),
          _outlined('Cleared!', 58, const [Color(0xFFFFE45C), Color(0xFFFFA81F)]),
        ],
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon();

  @override
  Widget build(BuildContext context) {
    const star = Icon(
      Icons.star_rounded,
      color: Color(0xFFFFC42E),
      size: 32,
      shadows: [Shadow(color: Color(0xFFE08A12), offset: Offset(0, 2))],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: puffyDecoration(
        radius: 24,
        colors: const [Color(0xFFFFFAF2), Color(0xFFFCE9D6)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          star,
          SizedBox(width: 10),
          Text(
            'Level Complete!',
            style: TextStyle(
              color: Color(0xFF6B1F6E),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          SizedBox(width: 10),
          star,
        ],
      ),
    );
  }
}

/// Cream card showing the solved level, with laurels and a check badge.
class _SolvedCard extends StatelessWidget {
  const _SolvedCard({required this.level, required this.check});

  final LevelDef level;
  final Animation<double> check;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF7EE), Color(0xFFFCE6D4)],
        ),
        border: Border.all(color: const Color(0xFFFFF3E6), width: 5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8322A).withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _GlowPainter())),
            Positioned.fill(
              bottom: 70,
              top: 16,
              left: 10,
              right: 10,
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return CustomPaint(
                    size: size,
                    painter: BoardPainter(
                      layout: BoardLayout(
                        cols: level.cols,
                        rows: level.rows,
                        size: size,
                        margin: 0.7,
                      ),
                      threads: level.threads,
                      colorOf: ropeColorsFor(level),
                    ),
                  );
                },
              ),
            ),
            const Positioned(
              left: 26,
              bottom: 20,
              child: CustomPaint(size: Size(70, 46), painter: _LaurelPainter()),
            ),
            Positioned(
              right: 26,
              bottom: 20,
              child: Transform.flip(
                flipX: true,
                child: const CustomPaint(
                  size: Size(70, 46),
                  painter: _LaurelPainter(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(
                child: ScaleTransition(scale: check, child: const _CheckBadge()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5BD95B), Color(0xFF1FA02E)],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F7A2E).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const _purple = Color(0xFF6B1F6E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(39),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEA6B), Color(0xFFFFC21F)],
          ),
          border: Border.all(color: const Color(0xFFFFF4B0), width: 2),
          boxShadow: [
            const BoxShadow(color: Color(0xFFE59A0C), offset: Offset(0, 6)),
            BoxShadow(
              color: const Color(0xFFB8322A).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 30),
            const Icon(Icons.play_arrow_rounded, color: _purple, size: 50),
            const SizedBox(width: 10),
            Container(
              width: 2,
              height: 40,
              color: const Color(0xFFE5A21A),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _purple,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _MainLink extends StatelessWidget {
  const _MainLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: 56,
      height: 2.5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            line,
            const SizedBox(width: 16),
            const Text(
              'Main',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 16),
            line,
          ],
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.42);
    canvas.drawCircle(
      c,
      size.width * 0.42,
      Paint()
        ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );
    final ray = Paint()..color = Colors.white.withValues(alpha: 0.35);
    const n = 16;
    final r = size.width;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final b = a + math.pi / n / 1.4;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r)
          ..lineTo(c.dx + math.cos(b) * r, c.dy + math.sin(b) * r)
          ..close(),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) => false;
}

/// Small golden laurel branch curving up to the right.
class _LaurelPainter extends CustomPainter {
  const _LaurelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFF2B630);
    final stem = Path()
      ..moveTo(size.width, size.height * 0.95)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.95,
        size.width * 0.05,
        size.height * 0.05,
      );
    canvas.drawPath(
      stem,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final leaf = Paint()..color = gold;
    final metric = stem.computeMetrics().first;
    for (var i = 1; i <= 4; i++) {
      final t = metric.getTangentForOffset(metric.length * i / 5)!;
      final angle = math.atan2(t.vector.dy, t.vector.dx);
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(t.position.dx, t.position.dy);
        canvas.rotate(angle + side * 0.75);
        canvas.drawOval(
          Rect.fromLTWH(0, -4.5, 17, 9),
          leaf,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LaurelPainter oldDelegate) => false;
}

class FailOverlay extends StatelessWidget {
  const FailOverlay({
    super.key,
    required this.onRetry,
    required this.onMain,
  });

  final VoidCallback onRetry;
  final VoidCallback onMain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Out of hearts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A thread was blocked. Try a different order.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.coral,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Try again'),
                ),
              ),
              TextButton(onPressed: onMain, child: const Text('Back home')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  _SunburstPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    const rays = 18;
    for (var i = 0; i < rays; i++) {
      final a0 = (i / rays) * math.pi * 2 + progress * 0.2;
      final a1 = a0 + math.pi / rays;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(a0) * size.longestSide,
          center.dy + math.sin(a0) * size.longestSide,
        )
        ..lineTo(
          center.dx + math.cos(a1) * size.longestSide,
          center.dy + math.sin(a1) * size.longestSide,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static const _colors = [
    Color(0xFFFFD43B),
    Color(0xFF7AD7F0),
    Color(0xFFB98CF5),
    Color(0xFF5FE39A),
    Color(0xFFFF7FD1),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var i = 0; i < 46; i++) {
      final x = rnd.nextDouble() * size.width;
      final startY = -40 - rnd.nextDouble() * size.height * 0.3;
      final fall = size.height * (0.35 + rnd.nextDouble() * 0.6);
      final y = startY + fall * Curves.easeOut.transform(progress);
      final spin = rnd.nextDouble() * math.pi + progress * (2 + rnd.nextDouble() * 4);
      final w = 8 + rnd.nextDouble() * 8;
      final paint = Paint()..color = _colors[i % _colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.6),
          const Radius.circular(2.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
