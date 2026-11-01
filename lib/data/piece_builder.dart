import '../models/dir.dart';
import '../models/grid_point.dart';
import '../models/thread_piece.dart';

ThreadPiece piece(
  String id,
  List<(int, int)> points, {
  int color = ThreadColors.navy,
}) {
  final vertices = [for (final p in points) GridPoint(p.$1, p.$2)];
  if (vertices.length < 2) {
    throw ArgumentError('Thread $id needs at least two vertices');
  }
  final facing = Dir.fromSegment(
    vertices[vertices.length - 2].c,
    vertices[vertices.length - 2].r,
    vertices.last.c,
    vertices.last.r,
  );
  return ThreadPiece(
    id: id,
    color: color,
    vertices: vertices,
    facing: facing,
  );
}

/// Inclusive orthogonal line from (c0,r0) to (c1,r1). Head is the last point.
List<(int, int)> line(int c0, int r0, int c1, int r1) {
  if (c0 != c1 && r0 != r1) {
    throw ArgumentError('Diagonal line ($c0,$r0)-($c1,$r1)');
  }
  final pts = <(int, int)>[];
  final dc = c1.compareTo(c0);
  final dr = r1.compareTo(r0);
  var c = c0;
  var r = r0;
  while (true) {
    pts.add((c, r));
    if (c == c1 && r == r1) break;
    c += dc;
    r += dr;
  }
  return pts;
}
