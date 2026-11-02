import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:thread_knot/data/piece_builder.dart';
import 'package:thread_knot/models/dir.dart';
import 'package:thread_knot/models/grid_point.dart';
import 'package:thread_knot/render/board_layout.dart';
import 'package:thread_knot/render/exit_crawl.dart';

void main() {
  final layout = BoardLayout(cols: 6, rows: 6, size: const Size(240, 240));

  test('cell size is capped', () {
    expect(layout.cell, lessThanOrEqualTo(layout.maxCell));
  });

  test('crawl at t=0 sits on the original vertices', () {
    final thread = piece('L', [(0, 2), (0, 3), (1, 3), (2, 3)]);
    final pose = crawlPose(thread: thread, layout: layout, t: 0);
    expect(pose.pixels.first, layout.point(const GridPoint(0, 2)));
    expect(
      (pose.pixels.last - layout.point(const GridPoint(2, 3))).distance,
      lessThan(1),
    );
    expect(pose.facing, Dir.right);
  });

  test('crawl at t=1 has left the original cells along facing', () {
    final thread = piece('L', [(0, 2), (0, 3), (1, 3), (2, 3)]);
    final start = crawlPose(thread: thread, layout: layout, t: 0);
    final end = crawlPose(thread: thread, layout: layout, t: 1);
    expect(end.pixels.last.dx, greaterThan(start.pixels.last.dx));
    expect(
      (end.pixels.last - layout.point(const GridPoint(2, 3))).distance,
      greaterThan(layout.cell),
    );
  });

  test('mid crawl keeps the yarn on orthogonal rails', () {
    final thread = piece('L', [(0, 2), (0, 3), (1, 3), (2, 3)]);
    final pose = crawlPose(thread: thread, layout: layout, t: 0.35);
    for (var i = 1; i < pose.pixels.length; i++) {
      final d = pose.pixels[i] - pose.pixels[i - 1];
      expect(d.dx.abs() < 0.01 || d.dy.abs() < 0.01, isTrue);
    }
  });
}
