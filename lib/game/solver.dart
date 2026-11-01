import '../models/dir.dart';
import '../models/level_def.dart';
import '../models/thread_piece.dart';
import 'occupancy.dart';

/// Because pieces only leave the board (they never move to new cells), any
/// currently free piece is a valid next move. Greedy peeling yields a solution
/// iff the packing is not deadlocked.
List<String>? solve(
  LevelDef level, {
  Iterable<ThreadPiece>? living,
}) {
  final remaining = List<ThreadPiece>.from(living ?? level.threads);
  final order = <String>[];

  while (remaining.isNotEmpty) {
    final occupancy = Occupancy.fromThreads(remaining);
    ThreadPiece? next;
    for (final thread in remaining) {
      if (isFree(thread, occupancy, level.cols, level.rows)) {
        next = thread;
        break;
      }
    }
    if (next == null) return null;
    order.add(next.id);
    remaining.removeWhere((thread) => thread.id == next!.id);
  }
  return order;
}

String? nextHintId(LevelDef level, Iterable<ThreadPiece> living) {
  final occupancy = Occupancy.fromThreads(living);
  ThreadPiece? best;
  var bestDist = 1 << 30;
  for (final thread in living) {
    if (!isFree(thread, occupancy, level.cols, level.rows)) continue;
    final dist = _edgeDistance(thread, level.cols, level.rows);
    if (dist < bestDist) {
      bestDist = dist;
      best = thread;
    }
  }
  return best?.id;
}

int _edgeDistance(ThreadPiece thread, int cols, int rows) {
  final head = thread.head;
  return switch (thread.facing) {
    Dir.right => cols - 1 - head.c,
    Dir.left => head.c,
    Dir.down => rows - 1 - head.r,
    Dir.up => head.r,
  };
}
