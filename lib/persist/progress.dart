import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

class ProgressStore extends ChangeNotifier {
  ProgressStore._(this._prefs);

  final SharedPreferences _prefs;

  static const _kIndex = 'campaignIndex';
  static const _kMax = 'maxUnlocked';
  static const _kCleared = 'levelsCleared';
  static const _kSound = 'soundOn';
  static const _kDailyDate = 'lastDailyDate';
  static const _kDailyDone = 'dailyCompleted';
  static const _kStreak = 'dailyStreak';
  static const _kProfile = 'profile';

  static Future<ProgressStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressStore._(prefs);
  }

  int get campaignIndex => _prefs.getInt(_kIndex) ?? 0;
  int get maxUnlocked => _prefs.getInt(_kMax) ?? 0;
  int get levelsCleared => _prefs.getInt(_kCleared) ?? 0;
  bool get soundOn => _prefs.getBool(_kSound) ?? true;
  int get dailyStreak => _prefs.getInt(_kStreak) ?? 0;

  String _todayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool dailyCompletedOn(DateTime date) {
    return (_prefs.getString(_kDailyDate) == _todayKey(date)) &&
        (_prefs.getBool(_kDailyDone) ?? false);
  }

  PlayerProfile get profile =>
      PlayerProfile.fromName(_prefs.getString(_kProfile));

  Future<void> setProfile(PlayerProfile value) async {
    await _prefs.setString(_kProfile, value.name);
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    await _prefs.setBool(_kSound, value);
    notifyListeners();
  }

  Future<void> completeCampaignLevel(int index, int totalLevels) async {
    final next = (index + 1).clamp(0, totalLevels - 1);
    final unlocked = next > maxUnlocked ? next : maxUnlocked;
    await _prefs.setInt(_kIndex, next);
    await _prefs.setInt(_kMax, unlocked);
    if (index >= levelsCleared) {
      await _prefs.setInt(_kCleared, index + 1);
    }
    notifyListeners();
  }

  Future<void> resetCampaign() async {
    await _prefs.setInt(_kIndex, 0);
    notifyListeners();
  }

  Future<void> completeDaily(DateTime date) async {
    final key = _todayKey(date);
    final last = _prefs.getString(_kDailyDate);
    final yesterday = date.subtract(const Duration(days: 1));
    var streak = 1;
    if (last == _todayKey(yesterday)) {
      streak = dailyStreak + 1;
    } else if (last == key) {
      streak = dailyStreak;
    }
    await _prefs.setString(_kDailyDate, key);
    await _prefs.setBool(_kDailyDone, true);
    await _prefs.setInt(_kStreak, streak);
    notifyListeners();
  }
}
