import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../game/game_controller.dart';
import '../models/level_def.dart';
import '../models/profile.dart';
import '../persist/progress.dart';
import '../theme/app_theme.dart';
import 'overlays/complete_overlay.dart';
import 'widgets/banners.dart';
import 'widgets/decor.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/hud.dart';
import 'widgets/thread_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.progress,
    required this.levelIndex,
    this.isDaily = false,
  });

  final ProgressStore progress;
  final int levelIndex;
  final bool isDaily;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late int _playIndex;
  late bool _daily;

  /// Profile that started the current level; the win is credited to it.
  late PlayerProfile _owner;
  bool _hideCoach = false;
  bool _showComplete = false;
  bool _showFail = false;

  @override
  void initState() {
    super.initState();
    _playIndex = widget.levelIndex;
    _daily = widget.isDaily;
    _owner = widget.progress.profile;
    _controller = GameController(_currentLevel);
  }

  LevelDef get _currentLevel =>
      _daily ? dailyLevelFor(DateTime.now()) : campaignLevelAt(_playIndex);

  void _bind(GameController next) {
    _controller.dispose();
    _controller = next;
  }

  void _reload(int index) {
    _playIndex = index;
    _daily = false;
    _owner = widget.progress.profile;
    _bind(GameController(campaignLevelAt(index)));
    setState(() {
      _showComplete = false;
      _showFail = false;
      _hideCoach = false;
    });
  }

  Future<void> _onWin() async {
    if (_daily) {
      await widget.progress.completeDaily(DateTime.now(), forProfile: _owner);
    } else {
      await widget.progress.completeCampaignLevel(
        _playIndex,
        campaignLevels.length,
        forProfile: _owner,
      );
    }
    if (!mounted) return;
    setState(() => _showComplete = true);
  }

  void _onLose() => setState(() => _showFail = true);

  void _openSettings() {
    showSettingsSheet(
      context,
      progress: widget.progress,
      onRestart: () {
        _controller.restart();
        setState(() {
          _hideCoach = false;
          _showFail = false;
        });
      },
      onMainMenu: () => Navigator.pop(context),
    );
  }

  void _hint() {
    final id = _controller.useHint();
    if (id == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.hintsLeft <= 0
                ? 'No hints left'
                : 'No free string right now',
          ),
        ),
      );
    }
  }

  Future<void> _confirmRestart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart level?'),
        content: const Text('Strings will return to their starting places.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    if (ok == true) {
      _controller.restart();
      setState(() {
        _hideCoach = false;
        _showFail = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = _controller.level;
    final isLast = !_daily && _playIndex >= campaignLevels.length - 1;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Stack(
        children: [
          const Positioned.fill(child: CozyBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      PuffyCircleButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 38,
                          color: Color(0xFFE8503C),
                        ),
                      ),
                      Expanded(
                        child: Center(child: HangingTag(label: level.title)),
                      ),
                      PuffyCircleButton(
                        onTap: _openSettings,
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 28,
                          color: Color(0xFFE8503C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return GameHud(
                      remaining: _controller.remainingCount,
                      lives: _controller.lives,
                      maxLives: level.lives,
                      difficulty: level.difficulty,
                    );
                  },
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: ThreadBoard(
                      controller: _controller,
                      onWin: _onWin,
                      onLose: _onLose,
                      onFirstMove: () {
                        if (!_hideCoach) {
                          setState(() => _hideCoach = true);
                        }
                      },
                    ),
                  ),
                ),
                if (level.coachMark != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _hideCoach ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: CoachBanner(message: level.coachMark!),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 56),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return CircleActionButton(
                            icon: Icons.lightbulb_rounded,
                            iconColor: const Color(0xFFFFC23A),
                            badge: _controller.hintsLeft,
                            onTap: _hint,
                          );
                        },
                      ),
                      CircleActionButton(
                        icon: Icons.refresh_rounded,
                        iconColor: const Color(0xFF14A89F),
                        onTap: _confirmRestart,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showComplete)
            CompleteOverlay(
              level: level,
              nextLabel: (_daily || isLast) ? 'Main' : 'Next Game',
              onNext: () {
                if (_daily || isLast) {
                  Navigator.pop(context);
                } else if (widget.progress.profile != _owner) {
                  // Player switched profiles: continue from their own save.
                  _reload(widget.progress.campaignIndex);
                } else {
                  _reload(_playIndex + 1);
                }
              },
              onMain: () => Navigator.pop(context),
            ),
          if (_showFail)
            FailOverlay(
              onRetry: () {
                _controller.restart();
                setState(() => _showFail = false);
              },
              onMain: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
