import '../game/occupancy.dart';
import '../models/dir.dart';
import '../models/grid_point.dart';
import '../models/level_def.dart';
import '../models/thread_piece.dart';

/// Knobs for one generated level.
class GenSpec {
  const GenSpec({
    required this.cols,
    required this.rows,
    required this.minLen,
    required this.maxLen,
    required this.maxBends,
    required this.minFree,
    required this.maxFree,
    required this.minDepth,
    required this.fill,
    this.maxFreeDuringPlay = 4,
  });

  final int cols;
  final int rows;

  /// Thread length in dots.
  final int minLen;
  final int maxLen;

  /// Max number of turns a single thread can take.
  final int maxBends;

  /// How many threads may be tappable when the level opens.
  final int minFree;
  final int maxFree;

  /// Most threads that may be tappable at once at any point while playing.
  final int maxFreeDuringPlay;

  /// Minimum number of "waves" needed to clear the board, where each wave
  /// removes every thread that is free at that moment. Higher = longer chains.
  final int minDepth;

  /// Target fraction of dots covered by threads.
  final double fill;
}

/// Stats for a level, used both to accept generated layouts and in tests.
class LevelStats {
  const LevelStats({
    required this.initialFree,
    required this.maxFreeDuringPlay,
    required this.depth,
    required this.fill,
    required this.directions,
    required this.bentThreads,
  });

  final int initialFree;
  final int maxFreeDuringPlay;
  final int depth;
  final double fill;
  final Set<Dir> directions;
  final int bentThreads;
}

LevelStats measureLevel(LevelDef level) {
  var living = List<ThreadPiece>.from(level.threads);
  var maxFree = 0;
  var initialFree = -1;
  var depth = 0;
  // Remove one free thread at a time to watch how many are open at once,
  // and count full "waves" separately for depth.
  while (living.isNotEmpty) {
    final occ = Occupancy.fromThreads(living);
    final free = [
      for (final t in living)
        if (isFree(t, occ, level.cols, level.rows)) t,
    ];
    if (free.isEmpty) break;
    if (initialFree < 0) initialFree = free.length;
    if (free.length > maxFree) maxFree = free.length;
    living = [...living]..remove(free.first);
  }
  living = List<ThreadPiece>.from(level.threads);
  while (living.isNotEmpty) {
    final occ = Occupancy.fromThreads(living);
    final free = {
      for (final t in living)
        if (isFree(t, occ, level.cols, level.rows)) t.id,
    };
    if (free.isEmpty) return _stats(level, initialFree, maxFree, -1);
    depth += 1;
    living = [
      for (final t in living)
        if (!free.contains(t.id)) t,
    ];
  }
  return _stats(level, initialFree, maxFree, depth);
}

LevelStats _stats(LevelDef level, int initialFree, int maxFree, int depth) {
  var cells = 0;
  var bent = 0;
  for (final t in level.threads) {
    cells += t.vertices.length;
    final v = t.vertices;
    for (var i = 2; i < v.length; i++) {
      if ((v[i].c - v[i - 2].c).abs() == 1 &&
          (v[i].r - v[i - 2].r).abs() == 1) {
        bent += 1;
        break;
      }
    }
  }
  return LevelStats(
    initialFree: initialFree,
    maxFreeDuringPlay: maxFree,
    depth: depth,
    fill: cells / (level.cols * level.rows),
    directions: {for (final t in level.threads) t.facing},
    bentThreads: bent,
  );
}

/// Small deterministic PRNG (mulberry32) so a level never changes between
/// app versions or platforms.
class _Rng {
  _Rng(int seed) : _s = seed & 0xFFFFFFFF;
  int _s;

  int next() {
    _s = (_s + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _s;
    t = _imul(t ^ (t >> 15), t | 1);
    t ^= (t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  static int _imul(int a, int b) => (a * b) & 0xFFFFFFFF;

  int nextInt(int max) => next() % max;
  double nextDouble() => next() / 0x100000000;
  T pick<T>(List<T> items) => items[nextInt(items.length)];
}

const _palette = [
  0xFFF2B33D, // yellow
  0xFF2BB3A8, // teal
  0xFFE85D4C, // red
  0xFF9A72DE, // purple
  0xFFEE7AA6, // pink
  0xFF5FBF5A, // green
  0xFF4F8FE6, // blue
  0xFFF58A3A, // orange
];

/// Builds a level whose threads are added in *reverse* solve order: each new
/// thread's exit path must be clear of every thread already on the board, so
/// the finished level is always solvable. New threads are steered to sit in
/// the exit path of threads that are still free, so only a couple of threads
/// are tappable at a time and the player has to find the one way through.
LevelDef generateLevel({
  required int id,
  required GenSpec spec,
  required int seed,
  String? difficulty,
  int attempts = 400,
}) {
  LevelDef? best;
  var bestScore = -1 << 30;
  for (var a = 0; a < attempts; a++) {
    final level = _tryGenerate(
      id,
      spec,
      _Rng(seed * 7919 + a * 104729 + 17),
      difficulty ?? 'Normal',
    );
    if (level == null) continue;
    final s = measureLevel(level);
    final ok =
        s.depth >= spec.minDepth &&
        s.initialFree >= spec.minFree &&
        s.initialFree <= spec.maxFree &&
        s.maxFreeDuringPlay <= spec.maxFreeDuringPlay &&
        s.fill >= spec.fill - 0.12;
    if (ok) return level;
    // Keep the closest miss in case nothing satisfies every rule.
    final score =
        s.depth * 10 -
        (s.initialFree - spec.maxFree).clamp(0, 99) * 40 -
        (spec.minFree - s.initialFree).clamp(0, 99) * 40 -
        (s.maxFreeDuringPlay - spec.maxFreeDuringPlay).clamp(0, 99) * 15 +
        (s.fill * 100).round();
    if (score > bestScore) {
      bestScore = score;
      best = level;
    }
  }
  return best!;
}

class _Placed {
  _Placed(this.cells, this.ray);
  final List<GridPoint> cells;
  final List<GridPoint> ray;
  bool blocked = false;
}

LevelDef? _tryGenerate(int id, GenSpec spec, _Rng rng, String difficulty) {
  final cols = spec.cols;
  final rows = spec.rows;
  final occupied = <GridPoint>{};
  final placed = <_Placed>[];
  final target = (cols * rows * spec.fill).round();
  var misses = 0;

  while (occupied.length < target && misses < 60) {
    final open = [
      for (final p in placed)
        if (!p.blocked) p,
    ];
    // Cells that would block a currently-free thread if covered.
    final hot = <GridPoint>[
      for (final p in open)
        for (final g in p.ray)
          if (!occupied.contains(g)) g,
    ];
    // Keep the number of free threads between minFree and maxFree: a new
    // thread is itself free, so once we're at the cap it must block one.
    final mustBlock = open.length >= spec.maxFree;
    final wantBlock = open.length >= spec.minFree;

    _Placed? chosen;
    var chosenScore = -1;
    for (var k = 0; k < 40; k++) {
      final start = (hot.isNotEmpty && rng.nextDouble() < 0.8)
          ? rng.pick(hot)
          : GridPoint(rng.nextInt(cols), rng.nextInt(rows));
      final cand = _walk(start, spec, rng, occupied);
      if (cand == null) continue;
      final cells = cand.toSet();
      final covers = open.where((p) => p.ray.any(cells.contains)).length;
      if (mustBlock && covers == 0) continue;
      final after = open.length - covers + 1;
      if (after < 1) continue;
      final score =
          (wantBlock ? covers * 100 : (covers == 0 ? 100 : 0)) +
          (after < spec.minFree ? -50 : 0) +
          cand.length * 3 +
          rng.nextInt(5);
      if (score > chosenScore) {
        chosenScore = score;
        chosen = _Placed(cand, _ray(cand, cols, rows));
      }
    }
    if (chosen == null) {
      misses += 1;
      continue;
    }
    final cells = chosen.cells.toSet();
    for (final p in open) {
      if (p.ray.any(cells.contains)) p.blocked = true;
    }
    occupied.addAll(cells);
    placed.add(chosen);
  }
  if (placed.length < 3) return null;

  final threads = <ThreadPiece>[];
  for (var i = 0; i < placed.length; i++) {
    final v = placed[i].cells;
    threads.add(
      ThreadPiece(
        id: 'g${id}_$i',
        color: _palette[(i * 3 + id) % _palette.length],
        vertices: v,
        facing: Dir.fromSegment(
          v[v.length - 2].c,
          v[v.length - 2].r,
          v.last.c,
          v.last.r,
        ),
      ),
    );
  }
  return LevelDef(
    id: id,
    title: 'Level $id',
    cols: cols,
    rows: rows,
    difficulty: difficulty,
    threads: threads,
  );
}

/// Exit path of a thread: every dot from just past the head to the edge.
List<GridPoint> _ray(List<GridPoint> v, int cols, int rows) {
  final dir = Dir.fromSegment(
    v[v.length - 2].c,
    v[v.length - 2].r,
    v.last.c,
    v.last.r,
  );
  final out = <GridPoint>[];
  var p = v.last.step(dir);
  while (p.inBoard(cols, rows)) {
    out.add(p);
    p = p.step(dir);
  }
  return out;
}

/// Random snake through empty dots. Returns null if it can't be made valid.
List<GridPoint>? _walk(
  GridPoint start,
  GenSpec spec,
  _Rng rng,
  Set<GridPoint> occupied,
) {
  if (!start.inBoard(spec.cols, spec.rows) || occupied.contains(start)) {
    return null;
  }
  final len = spec.minLen + rng.nextInt(spec.maxLen - spec.minLen + 1);
  final path = <GridPoint>[start];
  final used = <GridPoint>{start};
  var dir = rng.pick(Dir.values);
  var bends = 0;
  var straight = 0;
  while (path.length < len) {
    final options = <Dir>[];
    // Prefer going straight; turn only after at least 2 dots in a line so
    // threads read as clean L / U / S shapes.
    final canTurn = bends < spec.maxBends && straight >= 1;
    if (canTurn && rng.nextDouble() < 0.35) {
      options.addAll([
        for (final d in Dir.values)
          if (d != dir && d != dir.opposite) d,
      ]);
      options.add(dir);
    } else {
      options.add(dir);
      if (canTurn) {
        options.addAll([
          for (final d in Dir.values)
            if (d != dir && d != dir.opposite) d,
        ]);
      }
    }
    GridPoint? nextPoint;
    Dir? nextDir;
    for (final d in options) {
      final p = path.last.step(d);
      if (p.inBoard(spec.cols, spec.rows) &&
          !occupied.contains(p) &&
          !used.contains(p)) {
        nextPoint = p;
        nextDir = d;
        break;
      }
    }
    if (nextPoint == null) break;
    if (nextDir != dir) {
      bends += 1;
      straight = 0;
    } else {
      straight += 1;
    }
    dir = nextDir!;
    path.add(nextPoint);
    used.add(nextPoint);
  }
  if (path.length < spec.minLen) return null;
  // Randomly flip which end is the knot so heads face every direction.
  final v = rng.nextDouble() < 0.5 ? path : path.reversed.toList();
  // The knot's exit path must be clear of everything, including itself.
  final ray = _ray(v, spec.cols, spec.rows);
  if (ray.isEmpty) return null; // knot sitting on the edge looks odd
  for (final p in ray) {
    if (occupied.contains(p) || used.contains(p)) return null;
  }
  return v;
}
