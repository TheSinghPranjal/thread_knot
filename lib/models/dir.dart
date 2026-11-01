enum Dir {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Dir(this.dc, this.dr);

  final int dc;
  final int dr;

  Dir get opposite => switch (this) {
        Dir.up => Dir.down,
        Dir.down => Dir.up,
        Dir.left => Dir.right,
        Dir.right => Dir.left,
      };

  static Dir fromSegment(int c0, int r0, int c1, int r1) {
    final dc = c1 - c0;
    final dr = r1 - r0;
    if (dc == 0 && dr == -1) return Dir.up;
    if (dc == 0 && dr == 1) return Dir.down;
    if (dc == -1 && dr == 0) return Dir.left;
    if (dc == 1 && dr == 0) return Dir.right;
    throw ArgumentError('Vertices ($c0,$r0) and ($c1,$r1) are not adjacent');
  }
}
