import 'dart:convert';

import 'package:exochess_mobile/src/binding.dart';
import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

final _logger = Logger('PreferencesStorage');

abstract class Serializable {
  Map<String, dynamic> toJson();
}

/// A preference category with its storage key
enum PrefCategory {
  general('preferences.general'),
  home('preferences.home'),
  board('preferences.board'),
  analysis('preferences.analysis'),
  study('preferences.study'),
  overTheBoard('preferences.overTheBoard'),
  challenge('preferences.challenge'),
  gameSetup('preferences.gameSetup'),
  gameSeeks('preferences.gameSeeks'),
  game('preferences.game'),
  coordinateTraining('preferences.coordinateTraining'),
  openingExplorer('preferences.opening_explorer'),
  gameHistory('preferences.gameHistory'),
  puzzle('preferences.puzzle'),
  broadcast('preferences.broadcast'),
  engineEvaluation('preferences.engineEvaluation'),
  offlineComputerGame('preferences.offlineComputerGame'),
  log('preferences.log'),
  onboarding('preferences.onboarding');

  const PrefCategory(this.storageKey);

  final String storageKey;
}

/// A [Notifier] mixin to provide a way to store and retrieve preferences.
mixin PreferencesStorage<T extends Serializable> on Notifier<T> {
  T fromJson(Map<String, dynamic> json);
  T get defaults;

  PrefCategory get prefCategory;

  Future<void> save(T value) async {
    await ExoChessBinding.instance.sharedPreferences.setString(
      prefCategory.storageKey,
      jsonEncode(value.toJson()),
    );

    state = value;
  }

  T fetch() {
    final stored = ExoChessBinding.instance.sharedPreferences.getString(prefCategory.storageKey);
    if (stored == null) {
      return defaults;
    }
    try {
      return fromJson(jsonDecode(stored) as Map<String, dynamic>);
    } catch (e) {
      _logger.warning('Failed to decode $prefCategory preferences: $e');
      return defaults;
    }
  }
}

/// A [Notifier] mixin to provide a way to store and retrieve preferences per authUser.
mixin SessionPreferencesStorage<T extends Serializable> on Notifier<T> {
  T fromJson(Map<String, dynamic> json);
  T defaults({LightUser? user});

  PrefCategory get prefCategory;

  Future<void> save(T value) async {
    final authUser = ref.read(authControllerProvider);
    await ExoChessBinding.instance.sharedPreferences.setString(
      key(prefCategory.storageKey, authUser),
      jsonEncode(value.toJson()),
    );

    state = value;
  }

  T fetch() {
    final authUser = ref.watch(authControllerProvider);
    final storageKey = key(prefCategory.storageKey, authUser);
    final stored = ExoChessBinding.instance.sharedPreferences.getString(storageKey);
    
    if (stored == null) {
      debugPrint('DEBUG: SessionPreferencesStorage.fetch(\$prefCategory): No data for key \$storageKey. Returning defaults.');
      return defaults(user: authUser?.user);
    }
    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      debugPrint('DEBUG: SessionPreferencesStorage.fetch(\$prefCategory): Loaded data for key \$storageKey: \$decoded');
      return fromJson(decoded);
    } catch (e) {
      _logger.warning('Failed to decode \$prefCategory preferences: \$e');
      return defaults(user: authUser?.user);
    }
  }

  static String key(String key, AuthUser? authUser) => '$key.${authUser?.user.id ?? '**anon**'}';
}
