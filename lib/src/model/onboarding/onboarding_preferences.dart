import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/settings/preferences_storage.dart';

part 'onboarding_preferences.freezed.dart';
part 'onboarding_preferences.g.dart';

@Freezed(fromJson: true, toJson: true)
sealed class OnboardingPrefs with _$OnboardingPrefs implements Serializable {
  const factory OnboardingPrefs({
    /// Whether the user has completed or skipped onboarding.
    @Default(false) bool hasCompleted,

    /// The display name the user entered. Null if skipped.
    String? displayName,
  }) = _OnboardingPrefs;

  static const defaults = OnboardingPrefs();

  factory OnboardingPrefs.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPrefsFromJson(json);
}

final onboardingPreferencesProvider =
    NotifierProvider<OnboardingNotifier, OnboardingPrefs>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingPrefs>
    with PreferencesStorage<OnboardingPrefs> {
  @override
  final prefCategory = PrefCategory.onboarding;

  @override
  OnboardingPrefs get defaults => OnboardingPrefs.defaults;

  @override
  OnboardingPrefs fromJson(Map<String, dynamic> json) =>
      OnboardingPrefs.fromJson(json);

  @override
  OnboardingPrefs build() => fetch();

  /// Complete onboarding, optionally saving the user's display name.
  Future<void> complete({String? displayName}) =>
      save(state.copyWith(hasCompleted: true, displayName: displayName?.trim().isEmpty == true ? null : displayName?.trim()));

  /// Skip onboarding — name stays null; home greets with "Welcome, User!".
  Future<void> skip() => save(state.copyWith(hasCompleted: true));

  /// Reset onboarding so the flow shows again (used by "Replay app tour").
  Future<void> reset() => save(const OnboardingPrefs());
}
