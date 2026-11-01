import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thread_knot/app.dart';
import 'package:thread_knot/models/profile.dart';
import 'package:thread_knot/persist/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home shows Thread Knot and Continue opens a board',
      (tester) async {
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
}
