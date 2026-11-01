import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Dark tip banner. Wrap words in `*asterisks*` to highlight them in gold.
class CoachBanner extends StatelessWidget {
  const CoachBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final parts = message.split('*');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 20, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF55356A), Color(0xFF432955)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6A4A80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const _GlowingBulb(),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  for (var i = 0; i < parts.length; i++)
                    TextSpan(
                      text: parts[i],
                      style: i.isOdd
                          ? const TextStyle(
                              color: Color(0xFFFFC93C),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            )
                          : null,
                    ),
                ],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingBulb extends StatelessWidget {
  const _GlowingBulb();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _RaysPainter(),
        child: const Center(
          child: Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFFFC93C),
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero) + const Offset(0, -3);
    final paint = Paint()
      ..color = const Color(0xFFFFC93C)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final a = math.pi + i * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * 19, c + dir * 24, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) => false;
}
