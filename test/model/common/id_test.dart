import 'package:exochess_mobile/src/model/common/id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameId', () {
    test('accepts 8-character ID', () {
      const id = GameId('12345678');
      expect(id.value, '12345678');
    });

    test('accepts longer IDs (e.g. Chess.com)', () {
      const id = GameId('1234567890');
      expect(id.value, '1234567890');
    });

    test('isValid only for 8-character Lichess-style IDs', () {
      expect(const GameId('12345678').isValid, isTrue);
      expect(const GameId('1234567890').isValid, isFalse);
    });
  });

  group('GameAnyId', () {
    test('accepts any length', () {
      final id = GameAnyId('abc');
      expect(id.value, 'abc');
    });

    test('isFullId and isGameId work correctly', () {
      expect(GameAnyId('12345678').isGameId, isTrue);
      expect(GameAnyId('123456789012').isFullId, isTrue);
    });
  });
}
