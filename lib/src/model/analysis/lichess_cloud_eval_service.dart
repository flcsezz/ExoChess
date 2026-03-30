import 'dart:convert';

import 'package:chessigma_mobile/src/model/common/eval.dart';
import 'package:chessigma_mobile/src/network/http.dart';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider for [LichessCloudEvalService].
final lichessCloudEvalServiceProvider = Provider<LichessCloudEvalService>((Ref ref) {
  return LichessCloudEvalService(ref);
}, name: 'LichessCloudEvalServiceProvider');

/// Service to fetch chess position evaluations from the Lichess Cloud Evaluation API.
class LichessCloudEvalService {
  LichessCloudEvalService(this._ref);

  final Ref _ref;

  /// Fetches a cloud evaluation for the given [position] from Lichess.
  ///
  /// Returns `null` if the position is not found in the cloud or if a network error occurs.
  Future<CloudEval?> fetchEval(Position position, {int multiPv = 1}) async {
    final client = _ref.read(defaultClientProvider);
    final fen = position.fen;
    final url = Uri.parse('https://lichess.org/api/cloud-eval').replace(
      queryParameters: {
        'fen': fen,
        'multiPv': multiPv.toString(),
      },
    );

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        final depth = json['depth'] as int? ?? 0;
        final knodes = json['knodes'] as int? ?? 0;
        final pvsJson = json['pvs'] as List<dynamic>? ?? [];

        final pvs = pvsJson.map((pv) {
          final pvMap = pv as Map<String, dynamic>;
          final movesStr = pvMap['moves'] as String? ?? '';
          final moves = movesStr.split(' ').where((m) => m.isNotEmpty).toIList();
          return PvData(
            moves: moves,
            cp: pvMap['cp'] as int?,
            mate: pvMap['mate'] as int?,
          );
        }).toIList();

        if (pvs.isEmpty) return null;

        return CloudEval(
          position: position,
          depth: depth,
          nodes: knodes * 1000,
          pvs: pvs,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
