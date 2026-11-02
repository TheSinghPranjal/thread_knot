import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../persist/progress.dart';
import '../theme/app_theme.dart';
import 'widgets/daily_card.dart';
import 'widgets/decor.dart';
import 'widgets/settings_sheet.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key, required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return WaveBackdrop(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            showSettingsSheet(context, progress: progress),
                        child: ProfileAvatar(
                          profile: progress.profile,
                          size: 64,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team ${progress.profile.label}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink,
                              ),
                            ),
                            const Text(
                              'Little wins, kept in one place.',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      PuffyCircleButton(
                        size: 48,
                        onTap: () =>
                            showSettingsSheet(context, progress: progress),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Color(0xFFE8503C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _StatTile(
                    emoji: '🧵',
                    label: 'Levels cleared',
                    value:
                        '${progress.levelsCleared} / ${campaignLevels.length}',
                  ),
                  _StatTile(
                    emoji: '📍',
                    label: 'Now playing',
                    value: campaignLevelAt(progress.campaignIndex).title,
                  ),
                  _StatTile(
                    emoji: '☀️',
                    label: 'Daily streak',
                    value: '${progress.dailyStreak}',
                  ),
                  const Spacer(),
                  const Text(
                    'Monthly trophies are on the way.',
                    style: TextStyle(color: AppTheme.muted),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppTheme.muted)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}
