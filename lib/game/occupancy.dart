import '../models/grid_point.dart';
import '../models/thread_piece.dart';

class Occupancy {
  Occupancy(this.map);

  factory Occupancy.fromThreads(Iterable<ThreadPiece> threads) {
    final map = <GridPoint, String>{};
    for (final thread in threads) {
      for (final vertex in thread.vertices) {
        final existing = map[vertex];
        if (existing != null && existing != thread.id) {
          throw StateError(
            'Vertex $vertex occupied by both $existing and ${thread.id}',
          );
        }
        map[vertex] = thread.id;
      }
    }
    return Occupancy(map);
  }

  final Map<GridPoint, String> map;

  String? operator [](GridPoint point) => map[point];

  Occupancy without(String threadId) {
    return Occupancy({
      for (final entry in map.entries)
        if (entry.value != threadId) entry.key: entry.value,
    });
  }
}

bool isBlocked(ThreadPiece thread, Occupancy occupancy, int cols, int rows) {
  var point = thread.head;
  while (true) {
    point = point.step(thread.facing);
    if (!point.inBoard(cols, rows)) return false;
    final occupant = occupancy[point];
    if (occupant != null && occupant != thread.id) return true;
  }
}

bool isFree(ThreadPiece thread, Occupancy occupancy, int cols, int rows) =>
    !isBlocked(thread, occupancy, cols, rows);

List<ThreadPiece> freeThreads(
  Iterable<ThreadPiece> living,
  int cols,
  int rows,
) {
  final occupancy = Occupancy.fromThreads(living);
  return [
    for (final thread in living)
      if (isFree(thread, occupancy, cols, rows)) thread,
  ];
}
