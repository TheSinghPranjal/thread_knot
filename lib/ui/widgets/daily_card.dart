import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../render/knot.dart';
import '../../models/dir.dart';
import '../../theme/app_theme.dart';
import 'decor.dart';

class WaveBackdrop extends StatelessWidget {
  const WaveBackdrop({super.key, required this.child, this.yarnBalls = false});

  final Widget child;
  final bool yarnBalls;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CozyBackground(yarnBalls: yarnBalls)),
        child,
      ],
    );
  }
}

Path _starPath(Offset c, double outer, double inner) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outer : inner;
    final a = -math.pi / 2 + i * math.pi / 5;
    final p = c + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

void _sparkles(
  Canvas canvas,
  Offset c,
  double len,
  double from,
  double to, {
  int count = 3,
  Color color = const Color(0xFFFFD43B),
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = len * 0.32
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < count; i++) {
    final a = from + (to - from) * (count == 1 ? 0 : i / (count - 1));
    final d = Offset(math.cos(a), math.sin(a));
    canvas.drawLine(c + d * len * 0.6, c + d * len * 1.6, paint);
  }
}

class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    super.key,
    required this.date,
    required this.completed,
    required this.onPlay,
  });

  final DateTime date;
  final bool completed;
  final VoidCallback onPlay;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final label = '${_months[date.month - 1]} ${date.day}';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7B6B), Color(0xFFF2584B)],
        ),
        border: Border.all(color: const Color(0xFFFFA494), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coral.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _SunburstPainter()),
            ),
            Positioned(
              right: 4,
              top: 30,
              child: Transform.rotate(
                angle: 0.12,
                child: const CustomPaint(
                  size: Size(126, 126),
                  painter: _CalendarPainter(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFB347), Color(0xFFF57C1F)],
                          ),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DAILY CHALLENGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Done ✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1.05,
                      shadows: [
                        Shadow(
                          color: const Color(
                            0xFFB8322A,
                          ).withValues(alpha: 0.45),
                          offset: const Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 96),
                    child: Text(
                      completed
                          ? 'Nice work! Play it again for fun.'
                          : 'A calm little puzzle, just for today.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 10, 26, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFFFEDE6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFB8322A,
                            ).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFFF2453A),
                            size: 30,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            completed ? 'Play Again' : 'Play Today',
                            style: const TextStyle(
                              color: Color(0xFFF2453A),
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.78, size.height * 0.45);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.07);
    const n = 14;
    final r = size.width * 1.2;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      final b = a + math.pi / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r)
        ..lineTo(c.dx + math.cos(b) * r, c.dy + math.sin(b) * r)
        ..close();
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(
      c,
      size.height * 0.5,
      Paint()
        ..color = const Color(0xFFFFB199).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}

class _CalendarPainter extends CustomPainter {
  const _CalendarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final page = Rect.fromLTWH(w * 0.08, w * 0.2, w * 0.74, w * 0.68);
    RRect rr(Rect r) => RRect.fromRectAndRadius(r, Radius.circular(w * 0.12));

    // Shadow + stacked back pages.
    canvas.drawRRect(
      rr(page.shift(Offset(w * 0.06, w * 0.12))),
      Paint()
        ..color = const Color(0xFFA8302A).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(
      rr(page.shift(Offset(w * 0.05, w * 0.08))),
      Paint()..color = const Color(0xFFF2D3BF),
    );
    canvas.drawRRect(
      rr(page.shift(Offset(w * 0.025, w * 0.04))),
      Paint()..color = const Color(0xFFFBE6D8),
    );

    // Front page.
    canvas.drawRRect(
      rr(page),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFAF5), Color(0xFFFBE9DC)],
        ).createShader(page),
    );
    // Header band.
    final header = Rect.fromLTWH(
      page.left,
      page.top,
      page.width,
      page.height * 0.3,
    );
    canvas.save();
    canvas.clipRRect(rr(page));
    canvas.drawRect(
      header,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6F91), Color(0xFFE94B73)],
        ).createShader(header),
    );
    canvas.restore();

    // Rings.
    final ring = Paint()
      ..color = const Color(0xFF8E5BD0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    for (final x in [
      page.left + page.width * 0.28,
      page.left + page.width * 0.72,
    ]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, page.top + w * 0.02),
          width: w * 0.13,
          height: w * 0.2,
        ),
        math.pi * 1.05,
        math.pi * 1.1,
        false,
        ring,
      );
      canvas.drawCircle(
        Offset(x + w * 0.065, page.top + w * 0.06),
        w * 0.028,
        Paint()..color = const Color(0xFF6A3FA8),
      );
    }

    // Star.
    final starC = Offset(page.center.dx, page.top + page.height * 0.64);
    canvas.drawPath(
      _starPath(starC + Offset(0, w * 0.02), w * 0.2, w * 0.095),
      Paint()..color = const Color(0xFFE08A12),
    );
    canvas.drawPath(
      _starPath(starC, w * 0.2, w * 0.095),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE066), Color(0xFFFFB31F)],
        ).createShader(Rect.fromCircle(center: starC, radius: w * 0.2)),
    );

    _sparkles(
      canvas,
      Offset(w * 0.9, w * 0.1),
      w * 0.09,
      -math.pi * 0.75,
      -math.pi * 0.05,
    );
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter oldDelegate) => false;
}

/// Big glossy primary button with a play icon on the left.
class ToyButton extends StatelessWidget {
  const ToyButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 92,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(46),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE7A3), Color(0xFFFFC870)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB347).withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(44),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF7E6B), Color(0xFFE9473A)],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0xFFC0332A), offset: Offset(0, 5)),
            ],
          ),
          child: Stack(
            children: [
              // Top gloss.
              Positioned(
                left: 24,
                right: 24,
                top: 6,
                height: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 34),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 58,
                    shadows: [
                      Shadow(
                        color: const Color(0xFFA82A22).withValues(alpha: 0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 2,
                    height: 46,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            height: 1.05,
                            shadows: [
                              Shadow(
                                color: const Color(
                                  0xFFA82A22,
                                ).withValues(alpha: 0.5),
                                offset: const Offset(0, 2),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft cream pill used for secondary actions.
class SoftPillButton extends StatelessWidget {
  const SoftPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
        decoration: puffyDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFE8503C), size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE8503C),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Thread Knot" wordmark with a swirl logo and white outline.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 24.0 : 46.0;
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(fontSize * 0.95),
          painter: const _KnotMarkPainter(),
        ),
        SizedBox(width: fontSize * 0.18),
        Stack(
          children: [
            Text(
              'Thread Knot',
              style: style.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = fontSize * 0.2
                  ..strokeJoin = StrokeJoin.round
                  ..color = Colors.white,
                shadows: [
                  Shadow(
                    color: const Color(0xFFD08A6C).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Text(
              'Thread Knot',
              style: style.copyWith(color: const Color(0xFF2E1A47)),
            ),
          ],
        ),
      ],
    );
  }
}

class _KnotMarkPainter extends CustomPainter {
  const _KnotMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w * 0.55, w * 0.45);
    final swirl = Path()
      ..addArc(
        Rect.fromCircle(center: c, radius: w * 0.3),
        math.pi * 0.6,
        math.pi * 1.85,
      )
      ..moveTo(
        c.dx + w * 0.3 * math.cos(math.pi * 0.6),
        c.dy + w * 0.3 * math.sin(math.pi * 0.6),
      )
      ..quadraticBezierTo(w * 0.3, w * 0.98, w * 0.08, w * 0.78);
    Paint s(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(swirl, s(Colors.white, w * 0.34));
    canvas.drawPath(swirl, s(const Color(0xFFE9473A), w * 0.2));
    canvas.drawPath(
      swirl.shift(Offset(-w * 0.02, -w * 0.03)),
      s(const Color(0xFFFF9C88), w * 0.06),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Hero illustration: threads on a pegboard, one sliding off along its
/// clear path while the others wait their turn.
class KnotHero extends StatelessWidget {
  const KnotHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 300 / 170,
      child: CustomPaint(painter: _KnotHeroPainter()),
    );
  }
}

class _KnotHeroPainter extends CustomPainter {
  const _KnotHeroPainter();

  static const _teal = Color(0xFF22C3BA);
  static const _coral = Color(0xFFF0675A);
  static const _gold = Color(0xFFF7B52C);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 300;
    canvas.save();
    canvas.scale(s);
    const w = 15.0;
    const knotCell = 52.0;

    // Pegboard holes.
    final rim = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final hole = Paint()..color = const Color(0xFFD9A48A);
    final inner = Paint()..color = const Color(0xFFBF7F64);
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 3; j++) {
        final p = Offset(40 + i * 40.0, 40 + j * 45.0);
        canvas.drawCircle(p + const Offset(0, 1.5), 4.6, rim);
        canvas.drawCircle(p, 4, hole);
        canvas.drawCircle(p + const Offset(0, -0.9), 2.9, inner);
      }
    }

    void rope(Path p, Color c) =>
        paintRope(canvas: canvas, path: p, color: c, width: w);
    void knot(Offset at, Color c, Dir facing) => paintKnot(
      canvas: canvas,
      center: at,
      facing: facing,
      cell: knotCell,
      stroke: w,
      color: c,
    );

    // Gold: vertical, knot pointing up.
    rope(
      Path()
        ..moveTo(160, 130)
        ..lineTo(160, 40),
      _gold,
    );
    knot(const Offset(160, 40), _gold, Dir.up);

    // Teal: L-shape, knot pointing right, blocked by gold.
    rope(
      Path()
        ..moveTo(40, 130)
        ..lineTo(40, 85)
        ..lineTo(120, 85),
      _teal,
    );
    knot(const Offset(120, 85), _teal, Dir.right);

    // Coral: free path, sliding off to the right.
    final trail = Paint()
      ..color = _coral.withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var x = 196.0; x < 228; x += 12) {
      canvas.drawLine(Offset(x, 112), Offset(x + 6, 112), trail);
      canvas.drawLine(Offset(x + 4, 148), Offset(x + 10, 148), trail);
    }
    rope(
      Path()
        ..moveTo(214, 130)
        ..lineTo(266, 130),
      _coral,
    );
    knot(const Offset(266, 130), _coral, Dir.right);

    _sparkles(
      canvas,
      const Offset(282, 104),
      11,
      -math.pi * 0.55,
      math.pi * 0.05,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KnotHeroPainter oldDelegate) => false;
}
