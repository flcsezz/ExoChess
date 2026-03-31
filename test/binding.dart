import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:exochess_mobile/src/binding.dart';
import 'package:multistockfish/multistockfish.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/engine/fake_stockfish.dart';

/// The binding instance used in tests.
TestExoChessBinding get testBinding => TestExoChessBinding.instance;

/// Lichess binding for testing.
class TestExoChessBinding extends ExoChessBinding {
  TestExoChessBinding() {
    // Logger.root.level = Level.ALL;
    // Logger.root.onRecord.listen((record) {
    //   // ignore: avoid_print
    //   print(
    //     '${DateFormat(\'H:m:s.S\').format(record.time)} [${record.level}] ${record.loggerName}: ${record.message}',
    //   );
    // });
  }

  /// Initialize the binding if necessary, and ensure it is a [TestExoChessBinding].
  ///
  /// If there is an existing binding but it is not a [TestExoChessBinding],
  /// this method throws an error.
  factory TestExoChessBinding.ensureInitialized() {
    if (_instance == null) {
      TestExoChessBinding();
    }
    return instance;
  }

  /// The single instance of the binding.
  static TestExoChessBinding get instance => ExoChessBinding.checkInstance(_instance);
  static TestExoChessBinding? _instance;

  @override
  void initInstance() {
    super.initInstance();
    _instance = this;
  }

  /// Set the initial values for shared preferences.
  Future<void> setInitialSharedPreferencesValues(Map<String, Object> values) async {
    for (final entry in values.entries) {
      if (entry.value is String) {
        await sharedPreferences.setString(entry.key, entry.value as String);
      } else if (entry.value is bool) {
        await sharedPreferences.setBool(entry.key, entry.value as bool);
      } else if (entry.value is double) {
        await sharedPreferences.setDouble(entry.key, entry.value as double);
      } else if (entry.value is int) {
        await sharedPreferences.setInt(entry.key, entry.value as int);
      } else if (entry.value is List<String>) {
        await sharedPreferences.setStringList(entry.key, entry.value as List<String>);
      } else {
        throw ArgumentError.value(
          entry.value,
          'values',
          'Unsupported value type: ${entry.value.runtimeType}',
        );
      }
    }
  }

  FakeSharedPreferences? _sharedPreferences;

  @override
  int numAppStarts = 1;

  @override
  FakeSharedPreferences get sharedPreferences {
    return _sharedPreferences ??= FakeSharedPreferences();
  }

  /// Reset the binding instance.
  ///
  /// Should be called using [addTearDown] in tests.
  void reset() {
    _sharedPreferences = null;
    numAppStarts = 1;
  }

  Stockfish _stockfish = FakeStockfish();

  @override
  Stockfish get stockfish => _stockfish;

  set stockfish(Stockfish instance) {
    _stockfish = instance;
  }
}

class FakeSharedPreferences implements SharedPreferencesWithCache {
  final Map<String, dynamic> _values = {};

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    _values.clear();
  }

  @override
  bool containsKey(String key) {
    return _values.containsKey(key);
  }

  @override
  String? getString(String key) {
    return _values[key] as String?;
  }

  @override
  bool? getBool(String key) {
    return _values[key] as bool?;
  }

  @override
  double? getDouble(String key) {
    return _values[key] as double?;
  }

  @override
  int? getInt(String key) {
    return _values[key] as int?;
  }

  @override
  List<String>? getStringList(String key) {
    return _values[key] as List<String>?;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<void> setBool(String key, bool value) {
    _values[key] = value;
    return Future.value();
  }

  @override
  Future<void> setDouble(String key, double value) {
    _values[key] = value;
    return Future.value();
  }

  @override
  Future<void> setInt(String key, int value) {
    _values[key] = value;
    return Future.value();
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    _values[key] = value;
    return Future.value();
  }

  @override
  Object? get(String key) {
    return _values[key];
  }

  @override
  Set<String> get keys => _values.keys.toSet();

  @override
  Future<void> reloadCache() {
    return Future.value();
  }
}
