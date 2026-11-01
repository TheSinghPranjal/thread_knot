import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'decor.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.remaining,
    required this.lives,
    required this.maxLives,
    required this.difficulty,
  });

  final int remaining;
  final int lives;
  final int maxLives;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: puffyDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.show_chart_rounded,
                  size: 22,
                  color: Color(0xFF14A89F),
                ),
                const SizedBox(width: 6),
                Text(
                  '$remaining',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < maxLives; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: AnimatedScale(
                    scale: i < lives ? 1 : 0.85,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: GlossyHeart(filled: i < lives, size: 30),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: puffyDecoration(
              colors: const [Color(0xFFFFEBC4), Color(0xFFFFD08E)],
            ),
            child: Text(
              difficulty,
              style: const TextStyle(
                color: Color(0xFFE8601C),
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return PuffyCircleButton(
      onTap: onTap,
      size: 66,
      badge: badge,
      child: Icon(
        icon,
        color: iconColor ?? AppTheme.teal,
        size: 36,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
