import 'package:flutter_test/flutter_test.dart';
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
    expect(campaignLevels.length, greaterThanOrEqualTo(20));
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
          expect(seen.add(key), isTrue, reason: '${level.title} overlap at $key');
        }
      }
    }
  });
}
