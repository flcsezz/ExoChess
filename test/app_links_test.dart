import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exochess_mobile/src/app_links.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:exochess_mobile/src/view/puzzle/puzzle_screen.dart';
import 'package:exochess_mobile/src/view/study/study_screen.dart';
import 'package:exochess_mobile/src/view/tournament/tournament_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockBuildContext mockContext;

  setUp(() {
    mockContext = MockBuildContext();
  });

  group('resolveAppLinkUri', () {
    test('returns null for an empty path', () {
      final uri = Uri.parse('https://lichess.org/');
      final result = resolveAppLinkUri(mockContext, uri);
      expect(result, isNull);
    });

    test('resolves /study/{id} to StudyScreen route', () {
      final uri = Uri.parse('https://lichess.org/study/p9uY0321');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<StudyScreen>().having((s) => s.id, 'id', 'p9uY0321'),
        ),
      );
    });

    test('resolves /training/{id} to PuzzleScreen route', () {
      final uri = Uri.parse('https://lichess.org/training/61044');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<PuzzleScreen>().having((s) => s.puzzleId, 'id', '61044'),
        ),
      );
    });

    test('resolves /tournament/{id} to TournamentScreen route', () {
      final uri = Uri.parse('https://lichess.org/tournament/61044');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<TournamentScreen>().having((s) => s.id, 'tournament id', '61044'),
        ),
      );
    });

    test('resolves /gameid link', () {
      // lichess.org/gameid -> Opens analysis at the first move
      final uri = Uri.parse('https://lichess.org/qwertyui');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<AnalysisScreen>()
              .having((s) => s.options.gameId, 'id', 'qwertyui')
              .having((s) => s.options.initialMoveCursor, 'move number', 0),
        ),
      );
    });

    test('resolves /gameid analysis link with ply fragment', () {
      // lichess.org/gameid#20 -> Opens analysis at move 20
      final uri = Uri.parse('https://lichess.org/qwertyui#20');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<AnalysisScreen>()
              .having((s) => s.options.gameId, 'id', 'qwertyui')
              .having((s) => s.options.initialMoveCursor, 'move number', 20),
        ),
      );
    });

    test('resolves /gameid/black analysis link', () {
      final uri = Uri.parse('https://lichess.org/qwertyui/black');
      expect(
        resolveAppLinkUri(mockContext, uri)!.first,
        isA<MaterialScreenRoute>().having(
          (r) => r.screen,
          'screen',
          isA<AnalysisScreen>()
              .having((s) => s.options.gameId, 'id', 'qwertyui')
              .having((s) => s.options.orientation, 'player color', Side.black),
        ),
      );
    });
  });
}
