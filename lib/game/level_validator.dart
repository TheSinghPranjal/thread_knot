import '../models/dir.dart';
import '../models/grid_point.dart';
import '../models/level_def.dart';
import 'occupancy.dart';
import 'solver.dart';

class LevelValidationException implements Exception {
  LevelValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

void validateLevel(LevelDef level) {
  if (level.cols < 2 || level.rows < 2) {
    throw LevelValidationException('Board too small');
  }
  if (level.threads.isEmpty) {
    throw LevelValidationException('Level ${level.id} has no threads');
  }

  final seenIds = <String>{};
  final occupied = <GridPoint, String>{};

  for (final thread in level.threads) {
    if (!seenIds.add(thread.id)) {
      throw LevelValidationException('Duplicate thread id ${thread.id}');
    }
    if (thread.vertices.length < 2) {
      throw LevelValidationException('Thread ${thread.id} needs 2+ vertices');
    }
    for (var i = 1; i < thread.vertices.length; i++) {
      final a = thread.vertices[i - 1];
      final b = thread.vertices[i];
      if (!areOrthogonalNeighbors(a, b)) {
        throw LevelValidationException(
          'Thread ${thread.id} has a non-adjacent step $a -> $b',
        );
      }
    }
    final inferred = Dir.fromSegment(
      thread.vertices[thread.vertices.length - 2].c,
      thread.vertices[thread.vertices.length - 2].r,
      thread.head.c,
      thread.head.r,
    );
    if (inferred != thread.facing) {
      throw LevelValidationException(
        'Thread ${thread.id} facing ${thread.facing} does not match last segment',
      );
    }
    for (final vertex in thread.vertices) {
      if (!vertex.inBoard(level.cols, level.rows)) {
        throw LevelValidationException(
          'Thread ${thread.id} vertex $vertex is out of ${level.cols}x${level.rows}',
        );
      }
      final owner = occupied[vertex];
      if (owner != null) {
        throw LevelValidationException(
          'Vertex $vertex shared by $owner and ${thread.id}',
        );
      }
      occupied[vertex] = thread.id;
    }
  }

  Occupancy.fromThreads(level.threads);
  final frees = freeThreads(level.threads, level.cols, level.rows);
  if (frees.isEmpty) {
    throw LevelValidationException('Level ${level.id} has no free thread');
  }
  final order = solve(level);
  if (order == null) {
    throw LevelValidationException('Level ${level.id} is unsolvable');
  }
}
