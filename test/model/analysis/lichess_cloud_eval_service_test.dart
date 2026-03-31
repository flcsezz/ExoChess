import 'dart:convert';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:exochess_mobile/src/model/analysis/lichess_cloud_eval_service.dart';
import 'package:exochess_mobile/src/network/http.dart';

class MockClient extends Mock implements DefaultClient {}

void main() {
  late ProviderContainer container;
  late MockClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://lichess.org/api/cloud-eval'));
  });

  setUp(() {
    mockClient = MockClient();
    container = ProviderContainer(
      overrides: [
        defaultClientProvider.overrideWithValue(mockClient),
      ],
    );
  });

  test('fetchEval returns CloudEval on 200 OK', () async {
    final service = container.read(lichessCloudEvalServiceProvider);
    final position = Chess.initial;
    final fen = position.fen;

    final responseBody = {
      'fen': fen,
      'depth': 24,
      'knodes': 1234,
      'cp': 15,
      'pvs': [
        {
          'moves': 'e2e4 c7c5',
          'cp': 15
        }
      ]
    };

    when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
      (_) async => http.Response(jsonEncode(responseBody), 200),
    );

    final result = await service.fetchEval(position);

    expect(result, isNotNull);
    expect(result!.depth, 24);
    expect(result.nodes, 1234000);
    expect(result.pvs.first.moves.first, 'e2e4');
  });

  test('fetchEval returns null on 404', () async {
    final service = container.read(lichessCloudEvalServiceProvider);
    final position = Chess.initial;

    when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
      (_) async => http.Response('Not Found', 404),
    );

    final result = await service.fetchEval(position);

    expect(result, isNull);
  });
}
