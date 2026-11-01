import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/dir.dart';

Color _shade(Color c, double t) =>
    Color.lerp(c, const Color(0xFF3A1A10), t)!;
Color _tint(Color c, double t) => Color.lerp(c, Colors.white, t)!;

/// Paints a braided, rounded rope along [path].
void paintRope({
  required Canvas canvas,
  required Path path,
  required Color color,
  required double width,
  bool glow = false,
}) {
  Paint stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  if (glow) {
    canvas.drawPath(
      path,
      stroke(Colors.white.withValues(alpha: 0.9), width * 1.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.35),
    );
  }

  // Soft drop shadow on the board.
  canvas.drawPath(
    path.shift(Offset(0, width * 0.3)),
    stroke(const Color(0xFF8A4A2E).withValues(alpha: 0.22), width)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.22),
  );

  // Body: dark rim + main colour.
  canvas.drawPath(path, stroke(_shade(color, 0.22), width));
  canvas.drawPath(path, stroke(color, width * 0.8));

  // Braid: short diagonal strokes along the rope.
  final braid = stroke(_shade(color, 0.35).withValues(alpha: 0.55), width * 0.08);
  final braidLight = stroke(_tint(color, 0.4).withValues(alpha: 0.45), width * 0.06);
  final step = width * 0.38;
  for (final metric in path.computeMetrics()) {
    for (var d = step * 0.5; d < metric.length - step * 0.3; d += step) {
      final t = metric.getTangentForOffset(d);
      if (t == null) continue;
      final v = t.vector;
      final len = v.distance;
      if (len == 0) continue;
      final dir = v / len;
      final normal = Offset(-dir.dy, dir.dx);
      final half = width * 0.34;
      final skew = width * 0.2;
      final a = t.position + normal * half - dir * skew;
      final b = t.position - normal * half + dir * skew;
      canvas.drawLine(a, b, braid);
      canvas.drawLine(
        a + dir * (width * 0.09),
        b + dir * (width * 0.09),
        braidLight,
      );
    }
  }

  // Glossy highlight along the top-left edge.
  canvas.drawPath(
    path.shift(Offset(-width * 0.13, -width * 0.13)),
    stroke(_tint(color, 0.6).withValues(alpha: 0.5), width * 0.2),
  );
}

/// Paints a round, wound knot ball centred on [center].
void paintKnot({
  required Canvas canvas,
  required Offset center,
  required Dir facing,
  required double cell,
  required double stroke,
  required Color color,
  bool glow = false,
}) {
  final r = knotRadius(cell);
  final dark = _shade(color, 0.3);
  final light = _tint(color, 0.45);

  if (glow) {
    canvas.drawCircle(
      center,
      r * 1.35,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4),
    );
  }

  // Shadow.
  canvas.drawCircle(
    center + Offset(0, r * 0.28),
    r,
    Paint()
      ..color = const Color(0xFF8A4A2E).withValues(alpha: 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.22),
  );

  // Ball body.
  final ball = Rect.fromCircle(center: center, radius: r);
  canvas.drawCircle(
    center,
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.0,
        colors: [light, color, dark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(ball),
  );

  // Wound strands: three overlapping loops rotated around the centre.
  canvas.save();
  canvas.clipPath(Path()..addOval(ball));
  final base = math.atan2(facing.dr.toDouble(), facing.dc.toDouble());
  final strandDark = Paint()
    ..color = dark.withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.11
    ..strokeCap = StrokeCap.round;
  final strandLight = Paint()
    ..color = light.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.07
    ..strokeCap = StrokeCap.round;
  for (var k = 0; k < 3; k++) {
    final a = base + k * 2 * math.pi / 3;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(a);
    final loop = Rect.fromCenter(
      center: Offset(r * 0.32, 0),
      width: r * 1.25,
      height: r * 0.95,
    );
    canvas.drawArc(loop, -math.pi * 0.85, math.pi * 1.5, false, strandDark);
    canvas.drawArc(
      loop.deflate(r * 0.1),
      -math.pi * 0.8,
      math.pi * 1.3,
      false,
      strandLight,
    );
    canvas.restore();
  }
  canvas.restore();

  // Centre nub.
  final nub = Rect.fromCircle(center: center, radius: r * 0.3);
  canvas.drawCircle(
    center,
    r * 0.3,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [light, color, dark],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(nub),
  );

  // Rim and gloss.
  canvas.drawCircle(
    center,
    r,
    Paint()
      ..color = dark.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06,
  );
  canvas.drawOval(
    Rect.fromCenter(
      center: center + Offset(-r * 0.38, -r * 0.45),
      width: r * 0.5,
      height: r * 0.26,
    ),
    Paint()..color = Colors.white.withValues(alpha: 0.45),
  );
}

double knotRadius(double cell) => cell * 0.34;

Offset knotCenter(Offset headPixel, Dir facing, double cell) => headPixel;

bool hitKnot(Offset point, Offset center, double cell) {
  return (point - center).distance <= knotRadius(cell) + 8;
}

bool hitPolyline(Offset point, List<Offset> pixels, double hitPad) {
  for (var i = 1; i < pixels.length; i++) {
    if (_distanceToSegment(point, pixels[i - 1], pixels[i]) <= hitPad) {
      return true;
    }
  }
  return false;
}

double _distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.distanceSquared;
  if (len2 == 0) return (p - a).distance;
  var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
  t = t.clamp(0.0, 1.0);
  final proj = a + ab * t;
  return (p - proj).distance;
}
