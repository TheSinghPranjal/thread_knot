import 'package:flutter_test/flutter_test.dart';
import 'package:thread_knot/data/level_generator.dart';
import 'package:thread_knot/data/levels.dart';
import 'package:thread_knot/data/piece_builder.dart';
import 'package:thread_knot/game/level_validator.dart';
import 'package:thread_knot/game/occupancy.dart';
import 'package:thread_knot/game/solver.dart';
import 'package:thread_knot/models/level_def.dart';

void main() {
  test('2-string forced order is solvable outer-then-inner', () {
    final level = LevelDef(
      id: 2,
      title: 'Level 2',
      cols: 5,
      rows: 5,
      threads: [
        piece('outer', line(3, 2, 3, 0)),
        piece('inner', line(0, 2, 2, 2)),
      ],
    );
    final order = solve(level);
    expect(order, isNotNull);
    expect(order!.first, 'outer');
    expect(order.last, 'inner');
  });

  test('3-string L/U style level is solvable', () {
    final level = LevelDef(
      id: 3,
      title: 'Level 3',
      cols: 5,
      rows: 5,
      threads: [
        piece('right', line(4, 1, 4, 4)),
        piece('mid', line(0, 2, 3, 2)),
        piece('bottom', line(1, 4, 3, 4)),
      ],
    );
    validateLevel(level);
    final order = solve(level)!;
    expect(order.first, 'right');
    expect(order.toSet(), {'right', 'mid', 'bottom'});
  });

  test('every campaign level is valid and solvable', () {
    expect(campaignLevels.length, greaterThanOrEqualTo(100));
    for (final level in campaignLevels) {
      validateLevel(level);
      final occupancy = Occupancy.fromThreads(level.threads);
      expect(occupancy.map.length, greaterThan(0));
      expect(solve(level), isNotNull);
    }
  });

  test('no campaign level shares vertices', () {
    for (final level in campaignLevels) {
      final seen = <String>{};
      for (final thread in level.threads) {
        for (final vertex in thread.vertices) {
          final key = '${vertex.c},${vertex.r}';
          expect(
            seen.add(key),
            isTrue,
            reason: '${level.title} overlap at $key',
          );
        }
      }
    }
  });

  test('generated levels keep only 2-3 threads movable and get harder', () {
    var prevCells = 0;
    for (var i = 10; i < campaignLevels.length; i++) {
      final level = campaignLevels[i];
      final spec = specForLevel(level.id);
      final s = measureLevel(level);
      final why =
          '${level.title}: free=${s.initialFree} '
          'maxFree=${s.maxFreeDuringPlay} depth=${s.depth}';
      expect(s.initialFree, inInclusiveRange(2, 3), reason: why);
      expect(
        s.maxFreeDuringPlay,
        lessThanOrEqualTo(spec.maxFreeDuringPlay),
        reason: why,
      );
      expect(s.depth, greaterThanOrEqualTo(spec.minDepth), reason: why);
      expect(s.directions.length, greaterThanOrEqualTo(2), reason: why);
      expect(s.bentThreads, greaterThan(0), reason: why);
      // Boards only grow, apart from the small every-5th-level bump.
      final cells = level.cols * level.rows;
      if (level.id % 5 != 1) {
        expect(cells, greaterThanOrEqualTo(prevCells), reason: why);
      }
      prevCells = cells;
    }
  });

  test('generated levels are identical every time', () {
    final a = generateLevel(id: 77, spec: specForLevel(77), seed: 77);
    final b = generateLevel(id: 77, spec: specForLevel(77), seed: 77);
    expect(
      a.threads.map((t) => t.vertices.toString()).toList(),
      b.threads.map((t) => t.vertices.toString()).toList(),
    );
  });
}
