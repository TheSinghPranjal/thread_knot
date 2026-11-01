import 'package:flutter/foundation.dart';

import '../models/level_def.dart';
import '../models/thread_piece.dart';
import 'occupancy.dart';
import 'solver.dart';

enum GameStatus { playing, won, lost }

enum TapResult { ignored, blocked, exit }

class GameController extends ChangeNotifier {
  GameController(this.level) {
    restart();
  }

  final LevelDef level;

  late List<ThreadPiece> remaining;
  /// Threads currently sliding off the board. Several can leave at once.
  final List<ThreadPiece> exiting = [];
  GameStatus status = GameStatus.playing;
  int lives = 3;
  int hintsLeft = 2;
  String? highlightedId;
  String? bumpId;

  int get startCount => level.threads.length;
  int get remainingCount => remaining.length + exiting.length;
  int get clearedCount => startCount - remaining.length;

  Occupancy get occupancy => Occupancy.fromThreads(remaining);

  void restart() {
    remaining = List<ThreadPiece>.from(level.threads);
    exiting.clear();
    status = GameStatus.playing;
    lives = level.lives;
    hintsLeft = level.hints;
    highlightedId = null;
    bumpId = null;
    notifyListeners();
  }

  TapResult tap(String id) {
    if (status != GameStatus.playing) return TapResult.ignored;
    final index = remaining.indexWhere((thread) => thread.id == id);
    if (index < 0) return TapResult.ignored;

    final thread = remaining[index];
    final occ = occupancy;
    bumpId = null;

    if (isBlocked(thread, occ, level.cols, level.rows)) {
      lives -= 1;
      bumpId = id;
      highlightedId = null;
      if (lives <= 0) {
        status = GameStatus.lost;
      }
      notifyListeners();
      return TapResult.blocked;
    }

    remaining.removeAt(index);
    exiting.add(thread);
    highlightedId = null;
    bumpId = null;
    notifyListeners();
    return TapResult.exit;
  }

  void clearBump() {
    bumpId = null;
    notifyListeners();
  }

  void completeExit(String id) {
    exiting.removeWhere((t) => t.id == id);
    if (status == GameStatus.playing && remaining.isEmpty && exiting.isEmpty) {
      status = GameStatus.won;
    }
    notifyListeners();
  }

  String? useHint() {
    if (status != GameStatus.playing) return null;
    if (hintsLeft <= 0) return null;
    final id = nextHintId(level, remaining);
    if (id == null) return null;
    hintsLeft -= 1;
    highlightedId = id;
    notifyListeners();
    return id;
  }
}
