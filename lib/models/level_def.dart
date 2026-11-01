import 'thread_piece.dart';

class LevelDef {
  const LevelDef({
    required this.id,
    required this.title,
    required this.cols,
    required this.rows,
    required this.threads,
    this.difficulty = 'Normal',
    this.lives = 3,
    this.hints = 2,
    this.coachMark,
  });

  final int id;
  final String title;
  final String difficulty;
  final int cols;
  final int rows;
  final int lives;
  final int hints;
  final List<ThreadPiece> threads;
  final String? coachMark;
}
