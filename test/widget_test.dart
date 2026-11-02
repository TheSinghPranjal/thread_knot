import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thread_knot/app.dart';
import 'package:thread_knot/models/profile.dart';
import 'package:thread_knot/persist/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home shows Thread Knot and Continue opens a board', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressStore.load();
    await tester.pumpWidget(ThreadKnotApp(progress: progress));
    // Let the splash play and hand off to home.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Thread Knot'), findsWidgets);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsWidgets);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  test('Lion is the default profile and selection persists', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressStore.load();
    expect(progress.profile, PlayerProfile.lion);
    await progress.setProfile(PlayerProfile.eagle);
    final reloaded = await ProgressStore.load();
    expect(reloaded.profile, PlayerProfile.eagle);
  });

  test('Each profile keeps its own progress', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressStore.load();
    final day = DateTime(2026, 11, 2);

    await progress.setProfile(PlayerProfile.bear);
    await progress.completeCampaignLevel(0, 10);
    await progress.completeCampaignLevel(1, 10);
    await progress.completeDaily(day);

    await progress.setProfile(PlayerProfile.tiger);
    expect(progress.campaignIndex, 0);
    expect(progress.levelsCleared, 0);
    expect(progress.dailyStreak, 0);
    expect(progress.dailyCompletedOn(day), isFalse);
    await progress.completeCampaignLevel(0, 10);

    final reloaded = await ProgressStore.load();
    expect(reloaded.profile, PlayerProfile.tiger);
    expect(reloaded.campaignIndex, 1);
    await reloaded.setProfile(PlayerProfile.bear);
    expect(reloaded.campaignIndex, 2);
    expect(reloaded.levelsCleared, 2);
    expect(reloaded.dailyStreak, 1);
    expect(reloaded.dailyCompletedOn(day), isTrue);
  });

  test('Win is credited to the profile that started the level', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressStore.load();
    await progress.setProfile(PlayerProfile.horse);
    await progress.completeCampaignLevel(0, 10, forProfile: PlayerProfile.bear);
    expect(progress.campaignIndex, 0);
    await progress.setProfile(PlayerProfile.bear);
    expect(progress.campaignIndex, 1);
  });

  test('Legacy global save migrates to the selected profile', () async {
    SharedPreferences.setMockInitialValues({
      'profile': 'eagle',
      'campaignIndex': 4,
      'maxUnlocked': 4,
      'levelsCleared': 4,
      'dailyStreak': 3,
    });
    final progress = await ProgressStore.load();
    expect(progress.campaignIndex, 4);
    expect(progress.levelsCleared, 4);
    expect(progress.dailyStreak, 3);
    await progress.setProfile(PlayerProfile.lion);
    expect(progress.campaignIndex, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('campaignIndex'), isFalse);
  });
}
