import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';

/// A provider for [ChallengeService].
final challengeServiceProvider = Provider<ChallengeService>((Ref ref) {
  final service = ChallengeService(ref);
  ref.onDispose(() => service.dispose());
  return service;
}, name: 'ChallengeServiceProvider');

/// A service that listens to challenge events and shows notifications.
class ChallengeService {
  ChallengeService(this.ref);

  final Ref ref;

  /// Start listening to events.
  void start() {
    // Disabled for Chessigma
  }

  /// Accept a challenge and return the created game's full ID.
  Future<GameFullId?> acceptChallenge(ChallengeId id) async {
    return null;
  }

  /// Stop listening to challenge events from the server.
  void dispose() {
  }
}
