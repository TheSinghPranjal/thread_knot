import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thread_knot/data/levels.dart';
import 'package:thread_knot/game/game_controller.dart';
import 'package:thread_knot/models/thread_piece.dart';
import 'package:thread_knot/render/board_layout.dart';
import 'package:thread_knot/render/knot.dart';
import 'package:thread_knot/ui/widgets/thread_board.dart';

// Level 3: 'right' blocks 'mid' and 'bottom'; once it leaves, both are free.
GameController level3() => GameController(campaignLevelAt(2));

void main() {
  test('a second thread can leave while the first is still sliding', () {
    final c = level3();
    expect(c.tap('right'), TapResult.exit);
    expect(c.tap('mid'), TapResult.exit);
    expect(c.tap('bottom'), TapResult.exit);
    expect(c.exiting.map((t) => t.id), ['right', 'mid', 'bottom']);
    expect(c.remainingCount, 3);
  });

  test('the level is won only once every slide has finished', () {
    final c = level3();
    for (final id in ['right', 'mid', 'bottom']) {
      c.tap(id);
    }
    c.completeExit('right');
    c.completeExit('mid');
    expect(c.status, GameStatus.playing);
    c.completeExit('bottom');
    expect(c.status, GameStatus.won);
  });

  testWidgets('quick taps on the board are not dropped', (tester) async {
    final c = level3();
    var won = false;
    const size = Size(400, 400);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.fromSize(
            size: size,
            child: ThreadBoard(controller: c, onWin: () => won = true),
          ),
        ),
      ),
    );
    final board = tester.getTopLeft(find.byType(ThreadBoard));
    final layout = BoardLayout(
      cols: c.level.cols,
      rows: c.level.rows,
      size: size,
    );
    Offset knotOf(String id) {
      final ThreadPiece t = c.level.threads.firstWhere((t) => t.id == id);
      return board + knotCenter(layout.point(t.head), t.facing, layout.cell);
    }

    await tester.tapAt(knotOf('right'));
    await tester.pump(const Duration(milliseconds: 100));
    // Tap the next one while 'right' is still mid-slide.
    await tester.tapAt(knotOf('mid'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(knotOf('bottom'));

    expect(c.remaining, isEmpty);
    expect(c.lives, c.level.lives);
    await tester.pumpAndSettle();
    expect(c.exiting, isEmpty);
    expect(won, isTrue);
  });
}
