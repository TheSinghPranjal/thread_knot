import 'package:flutter/material.dart';

import '../../models/profile.dart';
import '../../persist/progress.dart';
import '../../theme/app_theme.dart';

/// Round avatar showing a profile's animal.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 56,
    this.selected = false,
  });

  final PlayerProfile profile;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(profile.color, Colors.white, 0.65)!,
            Color.lerp(profile.color, Colors.white, 0.3)!,
          ],
        ),
        border: Border.all(
          color: selected ? AppTheme.coral : Colors.white,
          width: selected ? 3.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (selected ? AppTheme.coral : profile.color)
                .withValues(alpha: selected ? 0.4 : 0.25),
            blurRadius: selected ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(profile.emoji, style: TextStyle(fontSize: size * 0.52)),
    );
  }
}

/// Row of the five selectable profiles.
class ProfilePicker extends StatelessWidget {
  const ProfilePicker({super.key, required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final current = progress.profile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final p in PlayerProfile.values)
          GestureDetector(
            onTap: () => progress.setProfile(p),
            child: Column(
              children: [
                AnimatedScale(
                  scale: p == current ? 1.08 : 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: ProfileAvatar(profile: p, selected: p == current),
                ),
                const SizedBox(height: 6),
                Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: p == current ? FontWeight.w900 : FontWeight.w600,
                    color: p == current ? AppTheme.coral : AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Settings bottom sheet: profile, sound, and optional level actions.
Future<void> showSettingsSheet(
  BuildContext context, {
  required ProgressStore progress,
  VoidCallback? onRestart,
  VoidCallback? onMainMenu,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppTheme.cream,
    isScrollControlled: true,
    builder: (context) {
      return ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfilePicker(progress: progress),
                  const SizedBox(height: 16),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Sound',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: progress.soundOn,
                    onChanged: progress.setSound,
                  ),
                  if (onRestart != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.refresh_rounded),
                      title: const Text('Restart level'),
                      onTap: () {
                        Navigator.pop(context);
                        onRestart();
                      },
                    ),
                  if (onMainMenu != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Main menu'),
                      onTap: () {
                        Navigator.pop(context);
                        onMainMenu();
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
