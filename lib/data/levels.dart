import '../game/level_validator.dart';
import '../models/level_def.dart';
import '../models/thread_piece.dart';
import 'piece_builder.dart';

final List<LevelDef> campaignLevels = List.unmodifiable([
  _level1,
  _level2,
  _level3,
  _level4,
  _level5,
  _level6,
  _level7,
  _level8,
  _level9,
  _level10,
  _level11,
  _level12,
  _level13,
  _level14,
  _packed(
    id: 15,
    title: 'Level 15',
    cols: 10,
    rows: 10,
    difficulty: 'Hard',
    rowSplits: const [
      [3, 6, 10],
      [4, 10],
      [2, 5, 8, 10],
      [6, 10],
      [3, 7, 10],
      [4, 8, 10],
      [2, 6, 10],
      [5, 10],
      [3, 6, 10],
      [4, 7, 10],
    ],
  ),
  _packed(
    id: 16,
    title: 'Level 16',
    cols: 10,
    rows: 10,
    difficulty: 'Hard',
    facingLeftRows: const {1, 4, 7},
    rowSplits: const [
      [2, 5, 9, 10],
      [3, 7, 10],
      [4, 8, 10],
      [2, 6, 10],
      [5, 10],
      [3, 6, 9, 10],
      [4, 10],
      [2, 5, 8, 10],
      [3, 7, 10],
      [6, 10],
    ],
  ),
  _columnPacked(
    id: 17,
    title: 'Level 17',
    cols: 10,
    rows: 12,
    difficulty: 'Hard',
    colSplits: const [
      [3, 7, 12],
      [4, 8, 12],
      [2, 6, 12],
      [5, 12],
      [3, 8, 12],
      [4, 9, 12],
      [2, 7, 12],
      [6, 12],
      [3, 6, 12],
      [4, 8, 12],
    ],
  ),
  _packed(
    id: 18,
    title: 'Level 18',
    cols: 12,
    rows: 10,
    difficulty: 'Hard',
    facingLeftRows: const {0, 3, 6, 9},
    crimsonRow: 5,
    rowSplits: const [
      [4, 8, 12],
      [3, 7, 12],
      [2, 6, 9, 12],
      [5, 12],
      [3, 8, 12],
      [4, 7, 12],
      [2, 5, 10, 12],
      [6, 12],
      [3, 6, 9, 12],
      [4, 8, 12],
    ],
  ),
  _level19,
  _trophyLevel20,
]);

LevelDef campaignLevelAt(int index) {
  final clamped = index.clamp(0, campaignLevels.length - 1);
  return campaignLevels[clamped];
}

int dailyLevelIndex(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  return 7 + (seed.abs() % 7);
}

LevelDef dailyLevelFor(DateTime date) => campaignLevels[dailyLevelIndex(date)];

void validateCampaign() {
  for (final level in campaignLevels) {
    validateLevel(level);
  }
}

final _level1 = LevelDef(
  id: 1,
  title: 'Level 1',
  cols: 5,
  rows: 5,
  coachMark: 'Tap the knot. If the path is clear, the string *slides out*.',
  threads: [
    piece('a', line(1, 2, 3, 2)),
  ],
);

final _level2 = LevelDef(
  id: 2,
  title: 'Level 2',
  cols: 5,
  rows: 5,
  coachMark: 'If another string is in front of the knot, it *cannot leave*.',
  threads: [
    piece('outer', line(3, 2, 3, 0)),
    piece('inner', line(0, 2, 2, 2)),
  ],
);

final _level3 = LevelDef(
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

final _level4 = LevelDef(
  id: 4,
  title: 'Level 4',
  cols: 6,
  rows: 6,
  threads: [
    piece('wrap', [
      (5, 5),
      (5, 4),
      (5, 3),
      (5, 2),
      (5, 1),
      (4, 1),
      (3, 1),
      (2, 1),
    ]),
    piece('hook', [
      (3, 2),
      (3, 3),
      (3, 4),
      (4, 4),
      (4, 3),
      (4, 2),
    ]),
    piece('rise', line(1, 5, 1, 2)),
    piece('stub', line(3, 5, 4, 5), color: ThreadColors.crimson),
  ],
);

final _level5 = LevelDef(
  id: 5,
  title: 'Level 5',
  cols: 6,
  rows: 6,
  threads: [
    piece('leftL', [(0, 1), (0, 2), (0, 3), (0, 4), (1, 4), (2, 4)]),
    piece('up', line(1, 3, 1, 0)),
    piece('u', [(2, 1), (2, 2), (2, 3), (3, 3), (3, 2), (3, 1)]),
    piece('right', line(5, 0, 5, 5)),
    piece('low', line(2, 5, 4, 5)),
  ],
);

final _level6 = LevelDef(
  id: 6,
  title: 'Level 6',
  cols: 6,
  rows: 6,
  threads: [
    piece('n', [(1, 4), (1, 3), (1, 2), (1, 1), (2, 1), (3, 1), (3, 2), (3, 3)]),
    piece('bar', line(0, 0, 4, 0)),
    piece('drop', line(5, 1, 5, 5)),
    piece('base', line(0, 5, 3, 5)),
    piece('mid', line(4, 2, 4, 4), color: ThreadColors.crimson),
    piece('dash', line(0, 2, 0, 4)),
  ],
);

final _level7 = LevelDef(
  id: 7,
  title: 'Level 7',
  cols: 6,
  rows: 6,
  threads: [
    piece('frameTop', line(0, 0, 5, 0)),
    piece('frameRight', line(5, 1, 5, 5)),
    piece('frameLeft', line(0, 5, 0, 1)),
    piece('innerU', [
      (1, 4),
      (1, 3),
      (1, 2),
      (2, 2),
      (3, 2),
      (3, 3),
      (3, 4),
    ]),
    piece('core', [(2, 3), (2, 4), (2, 5), (3, 5), (4, 5)]),
    piece('cap', line(4, 1, 4, 3)),
  ],
);

final _level8 = LevelDef(
  id: 8,
  title: 'Level 8',
  cols: 6,
  rows: 6,
  difficulty: 'Hard',
  threads: [
    piece('a', [(0, 2), (0, 3), (0, 4), (1, 4), (2, 4), (2, 5)]),
    piece('b', [(1, 0), (1, 1), (1, 2), (1, 3)]),
    piece('c', [(2, 0), (3, 0), (4, 0), (4, 1)]),
    piece('d', [(3, 1), (3, 2), (3, 3), (4, 3), (5, 3)]),
    piece('e', [(2, 1), (2, 2), (2, 3)]),
    piece('f', line(5, 0, 5, 2)),
    piece('g', line(4, 4, 4, 5), color: ThreadColors.crimson),
    piece('h', line(5, 4, 5, 5)),
  ],
);

final _level9 = LevelDef(
  id: 9,
  title: 'Level 9',
  cols: 8,
  rows: 8,
  threads: [
    piece('rimR', line(7, 0, 7, 7)),
    piece('rimB', line(0, 7, 6, 7)),
    piece('rimT', line(0, 0, 6, 0)),
    piece('col', line(0, 1, 0, 6)),
    piece('l1', [(1, 2), (2, 2), (3, 2), (3, 3), (3, 4)]),
    piece('u1', [(1, 5), (1, 4), (1, 3), (2, 3), (2, 4), (2, 5)]),
    piece('s', [(4, 1), (4, 2), (4, 3), (5, 3), (5, 2), (5, 1)]),
    piece('h', line(4, 5, 6, 5)),
    piece('v', line(6, 1, 6, 4)),
    piece('dot', line(4, 6, 5, 6), color: ThreadColors.crimson),
  ],
);

final _level10 = LevelDef(
  id: 10,
  title: 'Level 10',
  cols: 8,
  rows: 8,
  threads: [
    piece('spiral', [
      (1, 1),
      (2, 1),
      (3, 1),
      (4, 1),
      (5, 1),
      (6, 1),
      (6, 2),
      (6, 3),
      (6, 4),
      (5, 4),
      (4, 4),
      (4, 3),
    ]),
    piece('arm', line(0, 0, 7, 0)),
    piece('east', line(7, 1, 7, 7)),
    piece('west', line(0, 7, 0, 1)),
    piece('south', line(1, 7, 6, 7)),
    piece('plug', [(1, 3), (1, 4), (1, 5), (2, 5), (3, 5)]),
    piece('cup', [(2, 2), (2, 3), (3, 3), (3, 2)]),
    piece('pin', line(5, 5, 5, 6)),
    piece('lid', line(2, 6, 4, 6)),
    piece('nub', [(5, 2), (5, 3)]),
    piece('zag', [(2, 4), (3, 4)]),
  ],
);

final _level11 = _packed(
    id: 11,
    title: 'Level 11',
    cols: 8,
    rows: 8,
    rowSplits: const [
      [3, 8],
      [2, 5, 8],
      [4, 8],
      [2, 6, 8],
      [3, 5, 8],
      [4, 8],
      [2, 5, 8],
      [3, 6, 8],
    ],
);

final _level12 = _packed(
    id: 12,
    title: 'Level 12',
    cols: 8,
    rows: 8,
    difficulty: 'Hard',
    facingLeftRows: const {1, 4, 6},
    crimsonRow: 3,
    rowSplits: const [
      [2, 5, 8],
      [4, 8],
      [3, 6, 8],
      [2, 4, 8],
      [5, 8],
      [2, 6, 8],
      [3, 8],
      [4, 7, 8],
    ],
);

final _level13 = _packed(
    id: 13,
    title: 'Level 13',
    cols: 8,
    rows: 8,
    difficulty: 'Hard',
    facingLeftRows: const {0, 2, 5, 7},
    rowSplits: const [
      [3, 6, 8],
      [2, 5, 8],
      [4, 8],
      [3, 7, 8],
      [2, 4, 6, 8],
      [5, 8],
      [3, 6, 8],
      [2, 5, 8],
    ],
);

final _level14 = _packed(
    id: 14,
    title: 'Level 14',
    cols: 8,
    rows: 8,
    difficulty: 'Hard',
    facingLeftRows: const {2, 3, 6},
    crimsonRow: 7,
    rowSplits: const [
      [2, 4, 8],
      [3, 6, 8],
      [5, 8],
      [2, 5, 8],
      [4, 7, 8],
      [3, 8],
      [2, 4, 6, 8],
      [5, 8],
    ],
);

final _level19 = _packed(
    id: 19,
    title: 'Level 19',
    cols: 12,
    rows: 12,
    difficulty: 'Hard',
    facingLeftRows: const {1, 4, 7, 10},
    crimsonRow: 8,
    rowSplits: const [
      [3, 7, 12],
      [4, 8, 12],
      [2, 6, 9, 12],
      [5, 12],
      [3, 8, 12],
      [4, 7, 12],
      [2, 5, 9, 12],
      [6, 12],
      [3, 6, 12],
      [4, 8, 12],
      [2, 7, 12],
      [5, 9, 12],
    ],
);

final _trophyLevel20 = _packed(
  id: 20,
  title: 'Level 20',
  cols: 12,
  rows: 12,
  difficulty: 'Hard',
  facingLeftRows: const {2, 5, 8, 11},
  crimsonRow: 6,
  rowSplits: const [
    [4, 8, 12],
    [3, 6, 9, 12],
    [5, 12],
    [2, 7, 12],
    [4, 8, 12],
    [3, 6, 10, 12],
    [5, 9, 12],
    [2, 6, 12],
    [4, 7, 12],
    [3, 8, 12],
    [5, 12],
    [4, 8, 12],
  ],
);

LevelDef _packed({
  required int id,
  required String title,
  required int cols,
  required int rows,
  required List<List<int>> rowSplits,
  String difficulty = 'Normal',
  Set<int> facingLeftRows = const {},
  int crimsonRow = -1,
}) {
  final threads = <ThreadPiece>[];
  var n = 0;
  for (var r = 0; r < rows; r++) {
    var start = 0;
    for (final end in rowSplits[r]) {
      if (end - start >= 2) {
        final facingLeft = facingLeftRows.contains(r);
        final pts = facingLeft ? line(end - 1, r, start, r) : line(start, r, end - 1, r);
        final color =
            r == crimsonRow && start == rowSplits[r].first - (end - start)
                ? ThreadColors.crimson
                : (r == crimsonRow && start == 0
                    ? ThreadColors.crimson
                    : ThreadColors.navy);
        threads.add(piece('r${id}_$n', pts, color: color));
        n += 1;
      }
      start = end;
    }
  }
  return LevelDef(
    id: id,
    title: title,
    cols: cols,
    rows: rows,
    difficulty: difficulty,
    threads: threads,
  );
}

LevelDef _columnPacked({
  required int id,
  required String title,
  required int cols,
  required int rows,
  required List<List<int>> colSplits,
  String difficulty = 'Normal',
}) {
  final threads = <ThreadPiece>[];
  var n = 0;
  for (var c = 0; c < cols; c++) {
    var start = 0;
    for (final end in colSplits[c]) {
      if (end - start >= 2) {
        threads.add(piece('c${id}_$n', line(c, start, c, end - 1)));
        n += 1;
      }
      start = end;
    }
  }
  return LevelDef(
    id: id,
    title: title,
    cols: cols,
    rows: rows,
    difficulty: difficulty,
    threads: threads,
  );
}

