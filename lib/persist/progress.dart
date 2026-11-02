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

  /// Progress keys that are stored separately for each profile.
  static const _perProfileKeys = [
    _kIndex,
    _kMax,
    _kCleared,
    _kDailyDate,
    _kDailyDone,
    _kStreak,
  ];

  static Future<ProgressStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore._(prefs);
    await store._migrateLegacyProgress();
    return store;
  }

  /// Namespaces a progress key under the active profile, e.g.
  /// `profile.eagle.campaignIndex`.
  String _key(String base, [PlayerProfile? p]) =>
      'profile.${(p ?? profile).name}.$base';

  /// Older builds kept a single global save. Hand it to whichever profile was
  /// selected at the time so nobody loses progress, then drop the old keys.
  Future<void> _migrateLegacyProgress() async {
    final legacy = _perProfileKeys.where(_prefs.containsKey).toList();
    if (legacy.isEmpty) return;
    for (final base in legacy) {
      final target = _key(base);
      final value = _prefs.get(base);
      if (!_prefs.containsKey(target)) {
        if (value is int) {
          await _prefs.setInt(target, value);
        } else if (value is bool) {
          await _prefs.setBool(target, value);
        } else if (value is String) {
          await _prefs.setString(target, value);
        }
      }
      await _prefs.remove(base);
    }
  }

  int get campaignIndex => _prefs.getInt(_key(_kIndex)) ?? 0;
  int get maxUnlocked => _prefs.getInt(_key(_kMax)) ?? 0;
  int get levelsCleared => _prefs.getInt(_key(_kCleared)) ?? 0;
  bool get soundOn => _prefs.getBool(_kSound) ?? true;
  int get dailyStreak => _prefs.getInt(_key(_kStreak)) ?? 0;

  String _todayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool dailyCompletedOn(DateTime date) {
    return (_prefs.getString(_key(_kDailyDate)) == _todayKey(date)) &&
        (_prefs.getBool(_key(_kDailyDone)) ?? false);
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

  /// Records a campaign win. Pass [forProfile] to credit the profile that
  /// started the level, even if the player switched profiles mid-game.
  Future<void> completeCampaignLevel(
    int index,
    int totalLevels, {
    PlayerProfile? forProfile,
  }) async {
    final p = forProfile ?? profile;
    final next = (index + 1).clamp(0, totalLevels - 1);
    final max = _prefs.getInt(_key(_kMax, p)) ?? 0;
    final cleared = _prefs.getInt(_key(_kCleared, p)) ?? 0;
    await _prefs.setInt(_key(_kIndex, p), next);
    await _prefs.setInt(_key(_kMax, p), next > max ? next : max);
    if (index >= cleared) {
      await _prefs.setInt(_key(_kCleared, p), index + 1);
    }
    notifyListeners();
  }

  Future<void> resetCampaign() async {
    await _prefs.setInt(_key(_kIndex), 0);
    notifyListeners();
  }

  Future<void> completeDaily(DateTime date, {PlayerProfile? forProfile}) async {
    final p = forProfile ?? profile;
    final key = _todayKey(date);
    final last = _prefs.getString(_key(_kDailyDate, p));
    final current = _prefs.getInt(_key(_kStreak, p)) ?? 0;
    final yesterday = date.subtract(const Duration(days: 1));
    var streak = 1;
    if (last == _todayKey(yesterday)) {
      streak = current + 1;
    } else if (last == key) {
      streak = current;
    }
    await _prefs.setString(_key(_kDailyDate, p), key);
    await _prefs.setBool(_key(_kDailyDone, p), true);
    await _prefs.setInt(_key(_kStreak, p), streak);
    notifyListeners();
  }
}
