import 'package:exochess_mobile/src/model/tv/tv_channels_provider.dart';
import 'package:exochess_mobile/src/model/tv/tv_channel.dart';
import 'package:exochess_mobile/src/model/tv/tv_game.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/tv/tv_screen.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:exochess_mobile/src/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvChannelsScreen extends ConsumerWidget {
  const TvChannelsScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const TvChannelsScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(tvChannelsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('EXOCHESS TV', style: TextStyle(fontFamily: 'NDot', fontSize: 20)),
        centerTitle: true,
      ),
      body: channelsAsync.when(
        data: (channels) {
          final sortedChannels = TvChannel.values.where((c) => channels.containsKey(c)).toList();
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: sortedChannels.length,
            itemBuilder: (context, index) {
              final channel = sortedChannels[index];
              final tvGame = channels[channel]!;
              
              return _ChannelCard(
                channel: channel,
                tvGame: tvGame,
                isDark: isDark,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load TV channels: $err'),
              TextButton(
                onPressed: () => ref.invalidate(tvChannelsProvider),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.tvGame,
    required this.isDark,
  });

  final TvChannel channel;
  final TvGame tvGame;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Card(
      elevation: 0,
      color: isDark ? null : Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            TvScreen.buildRoute(context, channel: channel),
          );
        },
        borderRadius: Styles.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Opacity(
                  opacity: isDark ? 0.04 : 0.02,
                  child: Icon(channel.icon, size: 70, color: accentColor),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(channel.icon, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          channel.label.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'NDot',
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'WATCHING',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 8,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tvGame.user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tvGame.rating != null)
                    Text(
                      'RATING: ${tvGame.rating}',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 9,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
