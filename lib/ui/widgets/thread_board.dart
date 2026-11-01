import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import '../../models/thread_piece.dart';
import '../../render/board_layout.dart';
import '../../render/board_painter.dart';
import '../../render/knot.dart';

class ThreadBoard extends StatefulWidget {
  const ThreadBoard({
    super.key,
    required this.controller,
    this.onWin,
    this.onLose,
    this.onFirstMove,
  });

  final GameController controller;
  final VoidCallback? onWin;
  final VoidCallback? onLose;
  final VoidCallback? onFirstMove;

  @override
  State<ThreadBoard> createState() => _ThreadBoardState();
}

class _ThreadBoardState extends State<ThreadBoard>
    with TickerProviderStateMixin {
  late final AnimationController _exit;
  late final AnimationController _bump;
  late final Animation<double> _exitT;
  GameStatus _lastStatus = GameStatus.playing;

  GameController get c => widget.controller;

  Color _colorOf(ThreadPiece thread) => ropeColorsFor(c.level)(thread);

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _exitT = CurvedAnimation(parent: _exit, curve: Curves.easeInOut);
    _exit.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        c.completeExit();
        _exit.value = 0;
      }
    });
    _bump.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        c.clearBump();
        _bump.value = 0;
      }
    });
    c.addListener(_onCtrl);
  }

  @override
  void didUpdateWidget(covariant ThreadBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCtrl);
      widget.controller.addListener(_onCtrl);
    }
  }

  void _onCtrl() {
    if (_lastStatus != GameStatus.won && c.status == GameStatus.won) {
      widget.onWin?.call();
    }
    if (_lastStatus != GameStatus.lost && c.status == GameStatus.lost) {
      widget.onLose?.call();
    }
    _lastStatus = c.status;
    setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(_onCtrl);
    _exit.dispose();
    _bump.dispose();
    super.dispose();
  }

  void _handleTap(Offset local, Size size) {
    if (c.isBusy || c.status != GameStatus.playing) return;
    final layout = BoardLayout(
      cols: c.level.cols,
      rows: c.level.rows,
      size: size,
    );
    final id = _hitTest(local, layout, c.remaining);
    if (id == null) return;
    final result = c.tap(id);
    if (result == TapResult.exit) {
      widget.onFirstMove?.call();
      final extra = c.exiting == null
          ? 6
          : c.exiting!.vertices.length +
              (c.level.cols > c.level.rows ? c.level.cols : c.level.rows);
      final ms = (90 * extra).clamp(360, 900).round();
      _exit.duration = Duration(milliseconds: ms);
      _exit.forward(from: 0);
    } else if (result == TapResult.blocked) {
      widget.onFirstMove?.call();
      _bump.forward(from: 0);
    }
  }

  String? _hitTest(Offset local, BoardLayout layout, List<ThreadPiece> threads) {
    String? best;
    var bestDist = double.infinity;
    for (final thread in threads) {
      final pixels = [for (final v in thread.vertices) layout.point(v)];
      final knot = knotCenter(pixels.last, thread.facing, layout.cell);
      final knotDist = (local - knot).distance;
      if (knotDist <= knotRadius(layout.cell) + 12 && knotDist < bestDist) {
        bestDist = knotDist;
        best = thread.id;
        continue;
      }
      if (hitPolyline(local, pixels, layout.hitPad)) {
        var d = bestDist;
        for (var i = 1; i < pixels.length; i++) {
          final a = pixels[i - 1];
          final b = pixels[i];
          final ab = b - a;
          final len2 = ab.distanceSquared;
          var t = len2 == 0 ? 0.0 : ((local - a).dx * ab.dx + (local - a).dy * ab.dy) / len2;
          t = t.clamp(0.0, 1.0);
          final proj = a + ab * t;
          d = (local - proj).distance;
          if (d < bestDist) {
            bestDist = d;
            best = thread.id;
          }
        }
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_exitT, _bump]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final layout = BoardLayout(
              cols: c.level.cols,
              rows: c.level.rows,
              size: size,
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _handleTap(d.localPosition, size),
              child: CustomPaint(
                painter: BoardPainter(
                  layout: layout,
                  threads: c.remaining,
                  colorOf: _colorOf,
                  exiting: c.exiting,
                  exitT: _exitT.value,
                  bumpId: c.bumpId,
                  bumpT: _bump.value,
                  highlightedId: c.highlightedId,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        );
      },
    );
  }
}
