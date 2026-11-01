import 'dir.dart';

class GridPoint {
  const GridPoint(this.c, this.r);

  final int c;
  final int r;

  GridPoint step(Dir dir) => GridPoint(c + dir.dc, r + dir.dr);

  bool inBoard(int cols, int rows) => c >= 0 && r >= 0 && c < cols && r < rows;

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.c == c && other.r == r;

  @override
  int get hashCode => Object.hash(c, r);

  @override
  String toString() => '($c,$r)';
}

bool areOrthogonalNeighbors(GridPoint a, GridPoint b) =>
    (a.c - b.c).abs() + (a.r - b.r).abs() == 1;
