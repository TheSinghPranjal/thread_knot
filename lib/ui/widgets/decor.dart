import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Warm peach backdrop with soft hills and yarn balls in the bottom corners.
class CozyBackground extends StatelessWidget {
  const CozyBackground({super.key, this.yarnBalls = true});

  final bool yarnBalls;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _HillsPainter())),
        if (yarnBalls) ...[
          const Positioned(
            left: -80,
            bottom: -80,
            child: YarnBall(size: 190, color: Color(0xFFF0675A), angle: 0.4),
          ),
          const Positioned(
            right: -46,
            bottom: 10,
            child: YarnBall(size: 120, color: Color(0xFFF7B52C), angle: 1.2),
          ),
          const Positioned(
            right: -60,
            bottom: -80,
            child: YarnBall(size: 170, color: Color(0xFF22C3BA), angle: -0.5),
          ),
        ],
      ],
    );
  }
}

class _HillsPainter extends CustomPainter {
  const _HillsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF0E8), Color(0xFFFBE4D7)],
        ).createShader(Offset.zero & size),
    );
    // Glow top-right.
    canvas.drawCircle(
      Offset(w * 0.95, h * 0.28),
      w * 0.55,
      Paint()
        ..color = const Color(0xFFFFD9C6).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
    final back = Path()
      ..moveTo(0, h * 0.64)
      ..cubicTo(w * 0.3, h * 0.58, w * 0.55, h * 0.74, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      back,
      Paint()..color = const Color(0xFFF9D9C8).withValues(alpha: 0.55),
    );
    final front = Path()
      ..moveTo(0, h * 0.86)
      ..cubicTo(w * 0.35, h * 0.8, w * 0.6, h * 0.93, w, h * 0.84)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()..color = const Color(0xFFF6CDB9).withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _HillsPainter oldDelegate) => false;
}

/// A painted ball of yarn.
class YarnBall extends StatelessWidget {
  const YarnBall({
    super.key,
    required this.size,
    required this.color,
    this.angle = 0,
  });

  final double size;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.square(size),
        painter: _YarnPainter(color, angle),
      ),
    );
  }
}

class _YarnPainter extends CustomPainter {
  _YarnPainter(this.color, this.angle);

  final Color color;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final rect = Rect.fromCircle(center: c, radius: r);
    final dark = Color.lerp(color, const Color(0xFF3A1A10), 0.35)!;
    final light = Color.lerp(color, Colors.white, 0.45)!;

    canvas.drawCircle(
      c + Offset(0, r * 0.08),
      r,
      Paint()
        ..color = const Color(0xFF8A4A2E).withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.1),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [light, color, dark],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final strandDark = Paint()
      ..color = dark.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.045
      ..strokeCap = StrokeCap.round;
    final strandLight = Paint()
      ..color = light.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..strokeCap = StrokeCap.round;

    void band(double rot, double bend, double from, double to) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      for (var y = from; y <= to; y += r * 0.14) {
        final p = Path()
          ..moveTo(-r, y)
          ..quadraticBezierTo(0, y + r * bend, r, y);
        canvas.drawPath(p, strandDark);
        canvas.drawPath(p.shift(Offset(0, -r * 0.04)), strandLight);
      }
      canvas.restore();
    }

    band(angle, 0.35, -r, r);
    band(angle + math.pi / 2.2, 0.25, -r * 0.35, r * 0.35);

    canvas.restore();
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, dark.withValues(alpha: 0.35)],
          stops: const [0.7, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _YarnPainter old) =>
      old.color != color || old.angle != angle;
}

/// Soft, raised cream surface used for buttons and pills.
BoxDecoration puffyDecoration({
  BoxShape shape = BoxShape.rectangle,
  double radius = 999,
  List<Color> colors = const [Color(0xFFFFFCF8), Color(0xFFFBE7DA)],
}) {
  return BoxDecoration(
    shape: shape,
    borderRadius: shape == BoxShape.circle
        ? null
        : BorderRadius.circular(radius),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ),
    border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFD08A6C).withValues(alpha: 0.35),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class PuffyCircleButton extends StatelessWidget {
  const PuffyCircleButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 56,
    this.badge,
  });

  final VoidCallback onTap;
  final Widget child;
  final double size;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: puffyDecoration(shape: BoxShape.circle),
            child: child,
          ),
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5383B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Stitched leather-style tag hanging from two little ropes.
class HangingTag extends StatelessWidget {
  const HangingTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          decoration: puffyDecoration(
            radius: 22,
            colors: const [Color(0xFFFDEBD3), Color(0xFFF8D5B0)],
          ),
          foregroundDecoration: const _StitchDecoration(),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: -46,
          height: 70,
          child: IgnorePointer(child: CustomPaint(painter: _TagRopes())),
        ),
      ],
    );
  }
}

class _StitchDecoration extends Decoration {
  const _StitchDecoration();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _StitchPainter();
}

class _StitchPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    final rrect = RRect.fromRectAndRadius(
      (offset & size).deflate(6),
      const Radius.circular(16),
    );
    final paint = Paint()
      ..color = const Color(0xFFD9A06E).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 3.5), paint);
      }
    }
  }
}

class _TagRopes extends CustomPainter {
  const _TagRopes();

  @override
  void paint(Canvas canvas, Size size) {
    final rope = Paint()
      ..color = const Color(0xFFE88A3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final twist = Paint()
      ..color = const Color(0xFFB85E1E).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final hole = Paint()..color = const Color(0xFF6B3A1E);
    for (final x in [24.0, size.width - 24]) {
      final bottom = Offset(x, size.height - 8);
      final top = Offset(x + (x < size.width / 2 ? 12 : -12), 0);
      final path = Path()
        ..moveTo(bottom.dx, bottom.dy)
        ..quadraticBezierTo(bottom.dx, size.height * 0.4, top.dx, top.dy);
      canvas.drawPath(path, rope);
      for (final m in path.computeMetrics()) {
        for (var d = 2.0; d < m.length; d += 5) {
          final t = m.getTangentForOffset(d)!;
          canvas.drawLine(
            t.position + const Offset(-2, -1.5),
            t.position + const Offset(2, 1.5),
            twist,
          );
        }
      }
      canvas.drawCircle(bottom, 4, hole);
    }
  }

  @override
  bool shouldRepaint(covariant _TagRopes oldDelegate) => false;
}

/// A heart with a white outline and glossy fill.
class GlossyHeart extends StatelessWidget {
  const GlossyHeart({super.key, required this.filled, this.size = 34});

  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 6,
      height: size + 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: size + 8,
            color: Colors.white,
            shadows: [
              Shadow(
                color: const Color(0xFFD0506A).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: filled
                  ? const [Color(0xFFFF6F86), Color(0xFFE3173F)]
                  : const [Color(0xFFF1DED6), Color(0xFFE2C7BC)],
            ).createShader(rect),
            child: Icon(
              Icons.favorite_rounded,
              size: size,
              color: Colors.white,
            ),
          ),
          if (filled)
            Positioned(
              top: size * 0.3,
              left: size * 0.32,
              child: Container(
                width: size * 0.2,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
