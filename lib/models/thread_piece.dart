import 'dir.dart';
import 'grid_point.dart';

/// A string on the board. [vertices.last] is the knot (head).
class ThreadPiece {
  const ThreadPiece({
    required this.id,
    required this.color,
    required this.vertices,
    required this.facing,
  });

  final String id;

  /// ARGB color, e.g. `0xFF1B2A4A`.
  final int color;
  final List<GridPoint> vertices;
  final Dir facing;

  GridPoint get head => vertices.last;
  GridPoint get tail => vertices.first;

  ThreadPiece copyWith({List<GridPoint>? vertices, Dir? facing}) {
    return ThreadPiece(
      id: id,
      color: color,
      vertices: vertices ?? this.vertices,
      facing: facing ?? this.facing,
    );
  }
}

abstract final class ThreadColors {
  static const navy = 0xFF4A2C6A;
  static const crimson = 0xFFE85D4C;
  static const royal = 0xFF2BB3A8;
  static const highlight = 0xFF2BB3A8;
  static const bump = 0xFFFF5D73;
}
