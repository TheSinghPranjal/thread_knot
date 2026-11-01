import 'package:flutter/material.dart';

enum PlayerProfile {
  bear('Bear', '🐻', Color(0xFFC98A5B)),
  lion('Lion', '🦁', Color(0xFFF7B52C)),
  tiger('Tiger', '🐯', Color(0xFFF58A3A)),
  horse('Horse', '🐴', Color(0xFF9A72DE)),
  eagle('Eagle', '🦅', Color(0xFF22C3BA));

  const PlayerProfile(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;

  static const fallback = PlayerProfile.lion;

  static PlayerProfile fromName(String? name) => PlayerProfile.values
      .firstWhere((p) => p.name == name, orElse: () => fallback);
}
