import 'dart:collection';

import '../game/level_validator.dart';
import '../models/level_def.dart';
import '../models/thread_piece.dart';
import 'level_generator.dart';
import 'piece_builder.dart';

/// Total campaign length: 10 hand-made tutorial levels, then generated ones.
const int campaignLength = 120;
const int _handMadeCount = 10;

final List<LevelDef> _handMade = [
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
];

/// Levels are built on first use and cached, so startup stays instant.
final List<LevelDef> campaignLevels = _LazyLevels();

class _LazyLevels extends ListBase<LevelDef> {
  final List<LevelDef?> _cache = List.filled(campaignLength, null);

  @override
  int get length => campaignLength;

  @override
  set length(int value) => throw UnsupportedError('read-only');

  @override
  LevelDef operator [](int index) => _cache[index] ??= _buildLevel(index);

  @override
  void operator []=(int index, LevelDef value) =>
      throw UnsupportedError('read-only');
}

LevelDef _buildLevel(int index) {
  if (index < _handMadeCount) return _handMade[index];
  final id = index + 1;
  return generateLevel(
    id: id,
    spec: specForLevel(id),
    seed: id,
    difficulty: difficultyForLevel(id),
  );
}

/// Difficulty ramp for generated levels: bigger boards (more dots), longer
/// and more twisted threads, fewer tappable threads, longer unlock chains.
GenSpec specForLevel(int id) {
  final t = ((id - _handMadeCount - 1) / (campaignLength - _handMadeCount - 1))
      .clamp(0.0, 1.0);
  // Small bump every 5th level so the curve has peaks and breathers.
  final bump = id % 5 == 0 ? 1 : 0;
  final cols = (6 + (t * 4.99).floor() + (bump > 0 && t < 0.9 ? 1 : 0)).clamp(
    6,
    10,
  );
  final rows = (cols + 1 + (t * 3).floor()).clamp(7, 13);
  return GenSpec(
    cols: cols,
    rows: rows,
    minLen: t < 0.5 ? 2 : 3,
    maxLen: 4 + (t * 5).floor(),
    maxBends: 1 + (t * 3).floor(),
    minFree: 2,
    maxFree: t < 0.4 ? 3 : 2,
    maxFreeDuringPlay: t < 0.4 ? 4 : 3,
    minDepth: 3 + (t * 6).floor() + bump,
    fill: 0.6 + t * 0.15,
  );
}

String difficultyForLevel(int id) {
  if (id <= _handMadeCount) return id >= 8 ? 'Hard' : 'Normal';
  final t = (id - _handMadeCount) / (campaignLength - _handMadeCount);
  if (t < 0.25) return 'Normal';
  if (t < 0.6) return 'Hard';
  return 'Expert';
}

LevelDef campaignLevelAt(int index) {
  final clamped = index.clamp(0, campaignLevels.length - 1);
  return campaignLevels[clamped];
}

int dailyLevelIndex(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  // Pick from the middle of the campaign so the daily is a fair challenge.
  return 20 + (seed.abs() % 60);
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
  coachMark: 'Tap a knot. Its thread *slides out* the way the knot points.',
  threads: [piece('a', line(1, 2, 3, 2))],
);

final _level2 = LevelDef(
  id: 2,
  title: 'Level 2',
  cols: 5,
  rows: 5,
  coachMark: 'If another thread blocks the knot\'s path, it *can\'t move*.',
  threads: [piece('outer', line(3, 2, 3, 0)), piece('inner', line(0, 2, 2, 2))],
);

final _level3 = LevelDef(
  id: 3,
  title: 'Level 3',
  cols: 5,
  rows: 5,
  coachMark: 'Clear the threads in the *right order*. Look before you tap!',
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
    piece('hook', [(3, 2), (3, 3), (3, 4), (4, 4), (4, 3), (4, 2)]),
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
    piece('n', [
      (1, 4),
      (1, 3),
      (1, 2),
      (1, 1),
      (2, 1),
      (3, 1),
      (3, 2),
      (3, 3),
    ]),
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
    piece('innerU', [(1, 4), (1, 3), (1, 2), (2, 2), (3, 2), (3, 3), (3, 4)]),
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
