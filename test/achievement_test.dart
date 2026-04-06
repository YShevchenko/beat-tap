import 'package:flutter_test/flutter_test.dart';
import 'package:beat_tap_app/main.dart';

void main() {
  group('Achievement', () {
    test('creates achievement with correct properties', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test Title',
        description: 'Test Description',
        target: 50,
      );

      expect(achievement.id, 'test');
      expect(achievement.title, 'Test Title');
      expect(achievement.description, 'Test Description');
      expect(achievement.target, 50);
    });

    test('achievements list contains expected achievements', () {
      expect(achievements.length, 4);
      expect(achievements[0].id, 'first_hit');
      expect(achievements[1].id, 'combo_10');
      expect(achievements[2].id, 'combo_50');
      expect(achievements[3].id, 'score_1000');
    });

    test('achievement targets are in ascending order', () {
      for (int i = 0; i < achievements.length - 1; i++) {
        expect(
          achievements[i].target < achievements[i + 1].target,
          true,
          reason: 'Achievement targets should be in ascending order',
        );
      }
    });

    test('achievement ids are unique', () {
      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, achievements.length);
    });

    test('all achievements have valid targets', () {
      for (var achievement in achievements) {
        expect(achievement.target, greaterThan(0));
      }
    });
  });
}
