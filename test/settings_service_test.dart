import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beat_tap_app/main.dart';

void main() {
  group('SettingsService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with default values', () async {
      await SettingsService.instance.init();

      expect(SettingsService.instance.soundEnabled, true);
      expect(SettingsService.instance.vibrationEnabled, true);
      expect(SettingsService.instance.highScore, 0);
      expect(SettingsService.instance.maxCombo, 0);
      expect(SettingsService.instance.gamesPlayed, 0);
      expect(SettingsService.instance.hasSeenTutorial, false);
      expect(SettingsService.instance.unlockedAchievements, isEmpty);
    });

    test('loads saved preferences', () async {
      SharedPreferences.setMockInitialValues({
        'sound': false,
        'vibration': false,
        'highScore': 500,
        'maxCombo': 25,
        'gamesPlayed': 10,
        'hasSeenTutorial': true,
        'achievements': ['first_hit', 'combo_10'],
      });

      await SettingsService.instance.init();

      expect(SettingsService.instance.soundEnabled, false);
      expect(SettingsService.instance.vibrationEnabled, false);
      expect(SettingsService.instance.highScore, 500);
      expect(SettingsService.instance.maxCombo, 25);
      expect(SettingsService.instance.gamesPlayed, 10);
      expect(SettingsService.instance.hasSeenTutorial, true);
      expect(SettingsService.instance.unlockedAchievements, {'first_hit', 'combo_10'});
    });

    test('saveScore updates high score and max combo', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.saveScore(500, 20);

      expect(SettingsService.instance.highScore, 500);
      expect(SettingsService.instance.maxCombo, 20);
      expect(SettingsService.instance.gamesPlayed, 1);
    });

    test('saveScore updates only when values are higher', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.saveScore(500, 20);
      await SettingsService.instance.saveScore(300, 15);

      expect(SettingsService.instance.highScore, 500);
      expect(SettingsService.instance.maxCombo, 20);
      expect(SettingsService.instance.gamesPlayed, 2);
    });

    test('saveScore updates mixed values correctly', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.saveScore(500, 20);
      await SettingsService.instance.saveScore(600, 15);

      expect(SettingsService.instance.highScore, 600);
      expect(SettingsService.instance.maxCombo, 20);
    });

    test('setSoundEnabled updates setting', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.setSoundEnabled(false);

      expect(SettingsService.instance.soundEnabled, false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound'), false);
    });

    test('setVibrationEnabled updates setting', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.setVibrationEnabled(false);

      expect(SettingsService.instance.vibrationEnabled, false);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('vibration'), false);
    });

    test('markTutorialSeen updates flag', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.markTutorialSeen();

      expect(SettingsService.instance.hasSeenTutorial, true);
    });

    test('unlockAchievement adds new achievement', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.unlockAchievement('first_hit');

      expect(SettingsService.instance.unlockedAchievements, {'first_hit'});
    });

    test('unlockAchievement does not duplicate achievements', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.unlockAchievement('first_hit');
      await SettingsService.instance.unlockAchievement('first_hit');

      expect(SettingsService.instance.unlockedAchievements, {'first_hit'});
    });
  });
}
