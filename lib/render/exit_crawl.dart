import 'dart:ui';

import '../models/dir.dart';
import '../models/grid_point.dart';
import '../models/thread_piece.dart';
import 'board_layout.dart';
import 'knot.dart';

class CrawlPose {
  const CrawlPose({
    required this.pixels,
    required this.knot,
    required this.facing,
  });

  final List<Offset> pixels;
  final Offset knot;
  final Dir facing;
}

List<GridPoint> exitRail(ThreadPiece thread, {required int extra}) {
  final rail = List<GridPoint>.from(thread.vertices);
  var point = thread.head;
  for (var i = 0; i < extra; i++) {
    point = point.step(thread.facing);
    rail.add(point);
  }
  return rail;
}

int exitExtraCells(ThreadPiece thread, int cols, int rows) {
  return thread.vertices.length + (cols > rows ? cols : rows) + 2;
}

double polylineLength(List<Offset> points) {
  var length = 0.0;
  for (var i = 1; i < points.length; i++) {
    length += (points[i] - points[i - 1]).distance;
  }
  return length;
}

Offset pointAtDistance(List<Offset> points, List<double> cum, double dist) {
  if (points.isEmpty) return Offset.zero;
  if (dist <= 0) return points.first;
  final total = cum.last;
  if (dist >= total) return points.last;
  for (var i = 1; i < cum.length; i++) {
    if (dist <= cum[i]) {
      final span = cum[i] - cum[i - 1];
      final t = span == 0 ? 0.0 : (dist - cum[i - 1]) / span;
      return Offset.lerp(points[i - 1], points[i], t)!;
    }
  }
  return points.last;
}

List<double> cumulative(List<Offset> points) {
  final cum = List<double>.filled(points.length, 0);
  for (var i = 1; i < points.length; i++) {
    cum[i] = cum[i - 1] + (points[i] - points[i - 1]).distance;
  }
  return cum;
}

List<Offset> windowOnRail({
  required List<Offset> rail,
  required double start,
  required double length,
}) {
  if (rail.length < 2 || length <= 0) return rail;
  final cum = cumulative(rail);
  final total = cum.last;
  final from = start.clamp(0.0, total);
  final end = (start + length).clamp(0.0, total);

  final samples = <Offset>[pointAtDistance(rail, cum, from)];
  for (var i = 1; i < rail.length; i++) {
    if (cum[i] > from && cum[i] < end) {
      samples.add(rail[i]);
    }
  }
  final tail = pointAtDistance(rail, cum, end);
  if ((samples.last - tail).distance > 0.01) {
    samples.add(tail);
  }
  return samples;
}

Dir facingAlong(List<Offset> pixels, Dir fallback) {
  if (pixels.length < 2) return fallback;
  final delta = pixels.last - pixels[pixels.length - 2];
  if (delta.dx.abs() < 0.01 && delta.dy.abs() < 0.01) return fallback;
  if (delta.dx.abs() >= delta.dy.abs()) {
    return delta.dx >= 0 ? Dir.right : Dir.left;
  }
  return delta.dy >= 0 ? Dir.down : Dir.up;
}

CrawlPose crawlPose({
  required ThreadPiece thread,
  required BoardLayout layout,
  required double t,
}) {
  final extra = exitExtraCells(thread, layout.cols, layout.rows);
  final railPts = exitRail(thread, extra: extra);
  final rail = [for (final p in railPts) layout.point(p)];
  final yarn = [for (final p in thread.vertices) layout.point(p)];
  final yarnLen = polylineLength(yarn);
  final railLen = polylineLength(rail);
  final travel = (railLen - yarnLen).clamp(0.0, railLen);
  final start = travel * t.clamp(0.0, 1.0);
  final pixels = windowOnRail(rail: rail, start: start, length: yarnLen);
  final facing = facingAlong(pixels, thread.facing);
  final knot = pixels.isEmpty
      ? layout.point(thread.head)
      : knotCenter(pixels.last, facing, layout.cell);
  return CrawlPose(pixels: pixels, knot: knot, facing: facing);
}
