import 'package:flutter/widgets.dart';
import 'package:multistockfish/multistockfish.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton class that provides access to plugins and external APIs.
///
/// Only one instance of this class will be created during the app's lifetime.
/// See [AppExoChessBinding] for the concrete implementation.
///
/// Modeled after the Flutter framework's [WidgetsBinding] class.
///
/// The preferred way to mock or fake a plugin or external API is to create a
/// provider with riverpod because it gives more flexibility and control over
/// the behavior of the fake.
/// However, if the plugin is used in a way that doesn't allow for easy mocking
/// with riverpod, a test binding can be used to provide a fake implementation.
abstract class ExoChessBinding {
  ExoChessBinding() : assert(_instance == null) {
    initInstance();
  }

  /// The single instance of [ExoChessBinding].
  static ExoChessBinding get instance => checkInstance(_instance);
  static ExoChessBinding? _instance;

  @protected
  @mustCallSuper
  void initInstance() {
    _instance = this;
  }

  static T checkInstance<T extends ExoChessBinding>(T? instance) {
    assert(() {
      if (instance == null) {
        throw FlutterError.fromParts([
          ErrorSummary('ExoChess binding has not yet been initialized.'),
          ErrorHint(
            'In the app, this is done by the `AppExoChessBinding.ensureInitialized()` call '
            'in the `void main()` method.',
          ),
          ErrorHint(
            'In a test, one can call `TestExoChessBinding.ensureInitialized()` as the '
            "first line in the test's `main()` method to initialize the binding.",
          ),
        ]);
      }
      return true;
    }());
    return instance!;
  }

  /// Counts how many times the app has been (cold) started.
  int get numAppStarts;

  /// The shared preferences instance. Must be preloaded before use.
  ///
  /// This is a synchronous getter that throws an error if shared preferences
  /// have not yet been initialized.
  SharedPreferencesWithCache get sharedPreferences;

  /// The Stockfish singleton instance.
  Stockfish get stockfish;
}

/// A concrete implementation of [ExoChessBinding] for the app.
class AppExoChessBinding extends ExoChessBinding {
  AppExoChessBinding();

  /// Returns an instance of the binding that implements [ExoChessBinding].
  ///
  /// If no binding has yet been initialized, the [AppExoChessBinding] class is
  /// used to create and initialize one.
  factory AppExoChessBinding.ensureInitialized() {
    if (ExoChessBinding._instance == null) {
      AppExoChessBinding();
    }
    return ExoChessBinding.instance as AppExoChessBinding;
  }

  late Future<SharedPreferencesWithCache> _sharedPreferencesWithCache;
  SharedPreferencesWithCache? _syncSharedPreferencesWithCache;

  @override
  SharedPreferencesWithCache get sharedPreferences {
    if (_syncSharedPreferencesWithCache == null) {
      throw FlutterError.fromParts([
        ErrorSummary('Shared preferences have not yet been preloaded.'),
        ErrorHint(
          'In the app, this is done by the `await AppExoChessBinding.preloadSharedPreferences()` call '
          'in the `Future<void> main()` method.',
        ),
        ErrorHint(
          'In a test, one can call `TestExoChessBinding.setInitialSharedPreferencesValues({})` as the '
          "first line in the test's `main()` method.",
        ),
      ]);
    }
    return _syncSharedPreferencesWithCache!;
  }

  static const String _kNumAppStartsKey = 'app_starts';

  @override
  int get numAppStarts => sharedPreferences.getInt(_kNumAppStartsKey) ?? 0;

  /// Preload shared preferences.
  ///
  /// This should be called only once before the app starts. Must be called before
  /// [sharedPreferences] is accessed.
  Future<void> preloadSharedPreferences() async {
    _sharedPreferencesWithCache = SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    _syncSharedPreferencesWithCache = await _sharedPreferencesWithCache;

    final appStarts = sharedPreferences.getInt(_kNumAppStartsKey) ?? 0;
    sharedPreferences.setInt(_kNumAppStartsKey, appStarts + 1);
  }

  @override
  Stockfish get stockfish => Stockfish.instance;
}
