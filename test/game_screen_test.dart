import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_tap_app/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('MenuScreen', () {
    testWidgets('displays app title and icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.text('Beat Tap'), findsOneWidget);
      expect(find.text('Match the rhythm!'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsAtLeastNWidgets(1));
    });

    testWidgets('displays high score', (tester) async {
      SharedPreferences.setMockInitialValues({'highScore': 750});
      await SettingsService.instance.init();

      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.textContaining('Best: 750'), findsOneWidget);
    });

    testWidgets('displays max combo', (tester) async {
      SharedPreferences.setMockInitialValues({'maxCombo': 30});
      await SettingsService.instance.init();

      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.textContaining('Max Combo: 30'), findsOneWidget);
    });

    testWidgets('has start button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('has settings and achievements buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(1));
    });

    testWidgets('navigates to game screen on start', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MenuScreen()));
      await tester.pump();

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      expect(find.byType(GameScreen), findsOneWidget);
    });
  });

  group('GameScreen', () {
    testWidgets('initializes with starting values', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.textContaining('Score:'), findsOneWidget);
      expect(find.textContaining('Combo:'), findsOneWidget);
    });

    testWidgets('displays pause button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('shows pause overlay when paused', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('RESUME'), findsOneWidget);
      expect(find.text('QUIT'), findsOneWidget);
    });

    testWidgets('resumes game from pause', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      await tester.tap(find.text('RESUME'));
      await tester.pumpAndSettle();

      expect(find.text('PAUSED'), findsNothing);
    });
  });

  group('SettingsScreen', () {
    testWidgets('displays sound toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('displays vibration toggle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Vibration'), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('toggles sound setting', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(SettingsService.instance.soundEnabled, true);

      final soundSwitch = find.byType(SwitchListTile).first;
      await tester.tap(soundSwitch);
      await tester.pump();

      expect(SettingsService.instance.soundEnabled, false);
    });

    testWidgets('displays app version info', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();

      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('© 2026 Heldig Lab'), findsOneWidget);
      expect(find.text('heldig.lab@pm.me'), findsOneWidget);
    });
  });

  group('AchievementsScreen', () {
    testWidgets('displays all achievements', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.text('First Beat'), findsOneWidget);
      expect(find.text('Rhythm Rising'), findsOneWidget);
      expect(find.text('Beat Master'), findsOneWidget);
      expect(find.text('Music Legend'), findsOneWidget);
    });

    testWidgets('shows locked achievements', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('shows unlocked achievements', (tester) async {
      SharedPreferences.setMockInitialValues({'achievements': ['first_hit']});
      await SettingsService.instance.init();

      await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(1));
    });
  });
}
