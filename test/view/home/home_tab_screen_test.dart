import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:chessigma_mobile/src/app.dart';
import 'package:chessigma_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:chessigma_mobile/src/model/engine/nnue_service.dart';
import 'package:chessigma_mobile/src/model/game/game_storage.dart';
import 'package:chessigma_mobile/src/model/settings/preferences_storage.dart';
import 'package:chessigma_mobile/src/network/http.dart';
import 'package:chessigma_mobile/src/view/game/game_list_tile.dart';
import 'package:chessigma_mobile/src/view/home/home_tab_screen.dart';
import 'package:chessigma_mobile/src/widgets/feedback.dart';
import 'package:chessigma_mobile/src/widgets/platform.dart';

import '../../binding.dart';
import '../../example_data.dart';
import '../../mock_server_responses.dart';
import '../../model/auth/fake_auth_storage.dart';
import '../../model/engine/fake_nnue_service.dart';
import '../../network/fake_http_client_factory.dart';
import '../../test_helpers.dart';
import '../../test_provider_scope.dart';

void main() {
  group('Home online', () {
    testWidgets('shows Play button', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('no authUser, no stored game: shows welcome screen ', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('libre, no-ads, open source chess server.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('authUser, no played game: do not show welcome screen', (tester) async {
      int nbUserGamesRequests = 0;
      final mockClient = MockClient((request) {
        if (request.url.path == '/api/games/user/testuser') {
          nbUserGamesRequests++;
          return mockResponse('', 200);
        }
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        authUser: fakeAuthUser,
        overrides: {
          httpClientFactoryProvider: httpClientFactoryProvider.overrideWith(
            (ref) => FakeHttpClientFactory(() => mockClient),
          ),
        },
      );
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(nbUserGamesRequests, 1);
      expect(find.text('Sign in'), findsNothing);
    });

    testWidgets('no authUser, with stored games: shows list of recent games', (tester) async {
      final mockClient = MockClient((request) {
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        overrides: {
          httpClientFactoryProvider: httpClientFactoryProvider.overrideWith(
            (ref) => FakeHttpClientFactory(() => mockClient),
          ),
        },
      );
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateExportedGames(count: 3);
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('Anonymous'), findsNWidgets(3));
    });

    testWidgets('authUser, with played games: shows recent games', (tester) async {
      int nbUserGamesRequests = 0;
      final mockClient = MockClient((request) {
        if (request.url.path == '/api/games/user/testuser') {
          nbUserGamesRequests++;
          return mockResponse(mockUserRecentGameResponse('testUser'), 200);
        }
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        authUser: fakeAuthUser,
        overrides: {
          httpClientFactoryProvider: httpClientFactoryProvider.overrideWith(
            (ref) => FakeHttpClientFactory(() => mockClient),
          ),
        },
      );
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(nbUserGamesRequests, 1);
      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('MightyNanook'), findsOneWidget);
    });
  });

  group('Home offline', () {
    testWidgets('shows offline banner', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());

      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(OfflineBanner), findsOneWidget);
    });

    testWidgets('shows Play button', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());

      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('no authUser, no stored game: shows welcome screen ', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('libre, no-ads, open source chess server.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('no authUser, with stored games: shows list of recent games', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateExportedGames(count: 3);
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('Anonymous'), findsNWidgets(3));
    });

    testWidgets('authUser, with stored games: shows list of recent games', (tester) async {
      final app = await makeOfflineTestProviderScope(
        tester,
        child: const Application(),
        authUser: fakeAuthUser,
      );
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateExportedGames(count: 3, username: 'testUser');
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
    });

    group('home customization tip', () {
      const customizeTip =
          "Tip: You can add more widgets to the Home Screen or remove those you don't need!";
      testWidgets('shown when logged out', (tester) async {
        final app = await makeTestProviderScope(tester, child: const Application());

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsOneWidget);
      });

      testWidgets('shown when logged in', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          child: const Application(),
          authUser: fakeAuthUser,
        );

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsOneWidget);
      });

      testWidgets('Can be dismissed via button', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          child: const Application(),
          defaultPreferences: {kWelcomeMessageShownKey: true},
        );

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsOneWidget);
        await tester.tap(find.text('Dismiss'));
        await tester.pumpAndSettle(); // wait for tip widget to be removed
        expect(find.text(customizeTip), findsNothing);
      });

      testWidgets('Not shown if already dismissed', (tester) async {
        final app = await makeTestProviderScope(tester, child: const Application());

        TestChessigmaBinding.instance.sharedPreferences.setBool(
          'app_hide_home_widget_customization_tip',
          true,
        );

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsNothing);
      });

      testWidgets('Can be dismissed via going to settings', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          child: const Application(),
          defaultPreferences: {kWelcomeMessageShownKey: true},
        );

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsOneWidget);

        await tester.tap(find.text('Customize'));
        await tester.pumpAndSettle(); // wait for settings screen to open

        expect(find.widgetWithText(PlatformAppBar, 'Home widgets'), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, 'OK'));
        await tester.pumpAndSettle(); // wait for home screen to re-appear

        expect(find.text(customizeTip), findsNothing);
      });

      testWidgets('Not shown when > $kColdAppStartsHideCustomizationTipThreshold app starts', (
        tester,
      ) async {
        final app = await makeTestProviderScope(tester, child: const Application());

        TestChessigmaBinding.instance.numAppStarts = kColdAppStartsHideCustomizationTipThreshold + 1;

        await tester.pumpWidget(app);

        // wait for connectivity
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pump();

        expect(find.text(customizeTip), findsNothing);
      });
    });

    group('NNUE files missing tip', () {
      const nnueFilesMissingTip =
          'New Stockfish version available! Go to the settings to download the updated NNUE files.';
      testWidgets('Shown if engine pref is latest sf and NNUE files are missing', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          overrides: {
            nnueServiceProvider: nnueServiceProvider.overrideWithValue(
              FakeNnueServiceUnavailable(),
            ),
          },
          authUser: fakeAuthUser,
          defaultPreferences: {
            PrefCategory.engineEvaluation.storageKey: jsonEncode(
              EngineEvaluationPrefState.defaults
                  .copyWith(enginePref: ChessEnginePref.sfLatest)
                  .toJson(),
            ),
          },
          child: const Application(),
        );

        await tester.pumpWidget(app);

        // Wait for hasOutdatedNNUEFiles() future to complete
        await tester.pumpAndSettle();

        expect(find.text(nnueFilesMissingTip), findsOneWidget);
      });

      testWidgets('Not shown if nnue files are available', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          overrides: {
            nnueServiceProvider: nnueServiceProvider.overrideWithValue(FakeNnueService()),
          },
          authUser: fakeAuthUser,
          defaultPreferences: {
            PrefCategory.engineEvaluation.storageKey: jsonEncode(
              EngineEvaluationPrefState.defaults
                  .copyWith(enginePref: ChessEnginePref.sfLatest)
                  .toJson(),
            ),
          },
          child: const Application(),
        );

        await tester.pumpWidget(app);

        // Wait for hasOutdatedNNUEFiles() future to complete
        await tester.pumpAndSettle();

        expect(find.text(nnueFilesMissingTip), findsNothing);
      });

      testWidgets('Not shown if engine pref is sf16', (tester) async {
        final app = await makeTestProviderScope(
          tester,
          overrides: {
            nnueServiceProvider: nnueServiceProvider.overrideWithValue(
              FakeNnueServiceUnavailable(),
            ),
          },
          authUser: fakeAuthUser,
          defaultPreferences: {
            PrefCategory.engineEvaluation.storageKey: jsonEncode(
              EngineEvaluationPrefState.defaults
                  .copyWith(enginePref: ChessEnginePref.sf16)
                  .toJson(),
            ),
          },
          child: const Application(),
        );

        await tester.pumpWidget(app);

        // Wait for hasOutdatedNNUEFiles() future to complete
        await tester.pumpAndSettle();

        expect(find.text(nnueFilesMissingTip), findsNothing);
      });
    });
  });
}
