import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../persist/progress.dart';
import 'game_screen.dart';
import 'widgets/daily_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.progress});

  final ProgressStore progress;

  void _openGame(BuildContext context, {required int index, bool daily = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(
          progress: progress,
          levelIndex: index,
          isDaily: daily,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return WaveBackdrop(
      yarnBalls: true,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final level = campaignLevelAt(progress.campaignIndex);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  DailyChallengeCard(
                    date: now,
                    completed: progress.dailyCompletedOn(now),
                    onPlay: () => _openGame(
                      context,
                      index: dailyLevelIndex(now),
                      daily: true,
                    ),
                  ),
                  const Spacer(),
                  const Flexible(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: KnotHero(),
                    ),
                  ),
                  const FittedBox(child: BrandMark()),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap. Slide. Clear.',
                    style: TextStyle(
                      color: Color(0xFF6E4E86),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  ToyButton(
                    label: 'Continue',
                    subtitle: level.title,
                    onTap: () => _openGame(
                      context,
                      index: progress.campaignIndex,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SoftPillButton(
                    icon: Icons.refresh_rounded,
                    label: 'Start Over',
                    onTap: () async {
                      await progress.resetCampaign();
                      if (context.mounted) {
                        _openGame(context, index: 0);
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
