import 'dart:math' as math;
import 'dart:ui';

import '../models/grid_point.dart';

class BoardLayout {
  BoardLayout({
    required this.cols,
    required this.rows,
    required Size size,
    this.margin = 1.1,
    this.maxCell = 140,
  }) {
    // Leave [margin] cells of room on every side so knots and ropes on the
    // outer ring are never clipped.
    final spanW = (cols - 1) + margin * 2;
    final spanH = (rows - 1) + margin * 2;
    final next = spanW <= 0 || spanH <= 0
        ? 0.0
        : math.min(size.width / spanW, size.height / spanH);
    cell = math.max(0.0, math.min(next, maxCell));
    final gridW = cell * (cols - 1);
    final gridH = cell * (rows - 1);
    origin = Offset((size.width - gridW) / 2, (size.height - gridH) / 2);
  }

  final int cols;
  final int rows;
  final double margin;
  final double maxCell;
  late final double cell;
  late final Offset origin;

  Offset point(GridPoint p) => origin + Offset(p.c * cell, p.r * cell);

  /// Thickness of a rope.
  double get stroke => cell * 0.3;

  double get hitPad => math.min(math.max(stroke * 0.5 + 10, 14), cell * 0.5);
}
