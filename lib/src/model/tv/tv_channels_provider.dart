import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/tv/tv_repository.dart';

/// A provider that periodically fetches all current TV channels and their featured games.
final tvChannelsProvider = FutureProvider.autoDispose<TvChannels>((ref) async {
  final repository = ref.watch(tvRepositoryProvider);
  
  // Set up a timer to refresh the channels every 60 seconds.
  // We use autoDispose so the timer stops when the screen is not visible.
  final timer = Timer(const Duration(seconds: 60), () {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return repository.channels();
}, name: 'TvChannelsProvider');
