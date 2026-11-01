import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../persist/progress.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'widgets/daily_card.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key, required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final level = dailyLevelFor(now);
    return WaveBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final done = progress.dailyCompletedOn(now);
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily puzzle',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A fresh board every morning. No timer — just a little reset.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DailyChallengeCard(
                    date: now,
                    completed: done,
                    onPlay: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => GameScreen(
                            progress: progress,
                            levelIndex: dailyLevelIndex(now),
                            isDaily: true,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today’s board: ${level.title}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${level.difficulty}  ·  streak ${progress.dailyStreak}',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
