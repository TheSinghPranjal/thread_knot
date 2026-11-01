import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/grid_point.dart';
import '../models/level_def.dart';
import '../models/thread_piece.dart';
import 'board_layout.dart';
import 'exit_crawl.dart';
import 'knot.dart';

/// Rope colours, assigned by a thread's position in the level.
const ropePalette = <Color>[
  Color(0xFFF7B52C), // gold
  Color(0xFF22C3BA), // teal
  Color(0xFFF0675A), // coral
  Color(0xFF9A72DE), // lavender
  Color(0xFFFF7FA8), // pink
  Color(0xFF63C46E), // green
  Color(0xFF4F9BEF), // blue
];

/// Colour lookup that gives each thread a palette colour by its level order.
Color Function(ThreadPiece) ropeColorsFor(LevelDef level) {
  return (thread) {
    final i = level.threads.indexWhere((t) => t.id == thread.id);
    return ropePalette[(i < 0 ? 0 : i) % ropePalette.length];
  };
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.layout,
    required this.threads,
    required this.colorOf,
    this.exiting,
    this.exitT = 0,
    this.bumpId,
    this.bumpT = 0,
    this.highlightedId,
  });

  final BoardLayout layout;
  final List<ThreadPiece> threads;
  final Color Function(ThreadPiece) colorOf;
  final ThreadPiece? exiting;
  final double exitT;
  final String? bumpId;
  final double bumpT;
  final String? highlightedId;

  @override
  void paint(Canvas canvas, Size size) {
    _paintHoles(canvas);
    for (final thread in threads) {
      _paintThread(canvas, thread);
    }
    if (exiting != null) {
      _paintThread(canvas, exiting!, crawling: true);
    }
  }

  void _paintHoles(Canvas canvas) {
    final r = (layout.cell * 0.065).clamp(2.5, 9.0);
    final rim = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final hole = Paint()..color = const Color(0xFFD9A48A);
    final inner = Paint()..color = const Color(0xFFBF7F64);
    for (var c = 0; c < layout.cols; c++) {
      for (var row = 0; row < layout.rows; row++) {
        final p = layout.point(GridPoint(c, row));
        canvas.drawCircle(p + Offset(0, r * 0.3), r * 1.15, rim);
        canvas.drawCircle(p, r, hole);
        canvas.drawCircle(p + Offset(0, -r * 0.22), r * 0.72, inner);
      }
    }
  }

  void _paintThread(Canvas canvas, ThreadPiece thread, {bool crawling = false}) {
    List<Offset> pixels;
    Offset knotPos;
    var drawFacing = thread.facing;

    if (crawling) {
      final pose = crawlPose(thread: thread, layout: layout, t: exitT);
      pixels = pose.pixels;
      knotPos = pose.knot;
      drawFacing = pose.facing;
    } else {
      final shift = thread.id == bumpId
          ? Offset(thread.facing.dc.toDouble(), thread.facing.dr.toDouble()) *
              (layout.cell * 0.08 * math.sin(math.pi * bumpT))
          : Offset.zero;
      pixels = [for (final v in thread.vertices) layout.point(v) + shift];
      knotPos = knotCenter(pixels.last, thread.facing, layout.cell) + shift;
    }

    var color = colorOf(thread);
    if (thread.id == bumpId) {
      color = Color.lerp(color, const Color(ThreadColors.bump), 0.5)!;
    }
    final glow = thread.id == highlightedId;
    if (pixels.length < 2) return;

    final path = Path()..moveTo(pixels.first.dx, pixels.first.dy);
    for (var i = 1; i < pixels.length; i++) {
      path.lineTo(pixels[i].dx, pixels[i].dy);
    }
    path.lineTo(knotPos.dx, knotPos.dy);

    paintRope(
      canvas: canvas,
      path: path,
      color: color,
      width: layout.stroke,
      glow: glow,
    );
    paintKnot(
      canvas: canvas,
      center: knotPos,
      facing: drawFacing,
      cell: layout.cell,
      stroke: layout.stroke,
      color: color,
      glow: glow,
    );
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.exitT != exitT ||
        oldDelegate.bumpT != bumpT ||
        oldDelegate.highlightedId != highlightedId ||
        oldDelegate.bumpId != bumpId ||
        oldDelegate.exiting?.id != exiting?.id ||
        oldDelegate.threads.length != threads.length ||
        oldDelegate.layout.cell != layout.cell;
  }
}
