import 'package:flutter_test/flutter_test.dart';
import 'package:thread_knot/data/piece_builder.dart';
import 'package:thread_knot/game/occupancy.dart';
import 'package:thread_knot/models/level_def.dart';

void main() {
  test('empty lane is not blocked', () {
    final thread = piece('a', line(1, 2, 3, 2));
    final occ = Occupancy.fromThreads([thread]);
    expect(isBlocked(thread, occ, 5, 5), isFalse);
  });

  test('other vertex in the forward lane blocks', () {
    final mover = piece('a', line(0, 2, 2, 2));
    final wall = piece('b', line(3, 1, 3, 3));
    final occ = Occupancy.fromThreads([mover, wall]);
    expect(isBlocked(mover, occ, 5, 5), isTrue);
    expect(isBlocked(wall, occ, 5, 5), isFalse);
  });

  test('vertex behind the head does not block', () {
    final mover = piece('a', line(1, 2, 3, 2));
    final behind = piece('b', line(0, 1, 0, 3));
    final occ = Occupancy.fromThreads([mover, behind]);
    expect(isBlocked(mover, occ, 5, 5), isFalse);
  });

  test('own elbow does not block', () {
    final ell = piece('L', [(0, 2), (1, 2), (2, 2), (2, 1), (2, 0)]);
    final occ = Occupancy.fromThreads([ell]);
    expect(isBlocked(ell, occ, 5, 5), isFalse);
  });

  test('after removal a blocked piece becomes free', () {
    final outer = piece('outer', line(3, 2, 3, 0));
    final inner = piece('inner', line(0, 2, 2, 2));
    final before = Occupancy.fromThreads([outer, inner]);
    expect(isBlocked(inner, before, 5, 5), isTrue);
    final after = Occupancy.fromThreads([inner]);
    expect(isBlocked(inner, after, 5, 5), isFalse);
  });

  test('level 2 inner cannot leave first', () {
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
    final occ = Occupancy.fromThreads(level.threads);
    final inner = level.threads.firstWhere((t) => t.id == 'inner');
    final outer = level.threads.firstWhere((t) => t.id == 'outer');
    expect(isFree(outer, occ, 5, 5), isTrue);
    expect(isFree(inner, occ, 5, 5), isFalse);
  });
}
