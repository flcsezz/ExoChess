import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/user/leaderboard.dart';
import 'package:exochess_mobile/src/model/user/user_repository_providers.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/user/user_or_profile_screen.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/user.dart';

/// Create a Screen with Top 10 players for each Lichess Variant
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const LeaderboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.leaderboard.toUpperCase(),
          style: const TextStyle(fontFamily: 'NDot'),
        ),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return leaderboard.when(
      data: (data) {
        final List<Widget> list = [
          _Leaderboard(data.bullet, ExoChessIcons.bullet, 'BULLET'),
          _Leaderboard(data.blitz, ExoChessIcons.blitz, 'BLITZ'),
          _Leaderboard(data.rapid, ExoChessIcons.rapid, 'RAPID'),
          _Leaderboard(data.classical, ExoChessIcons.classical, 'CLASSICAL'),
          _Leaderboard(data.ultrabullet, ExoChessIcons.ultrabullet, 'ULTRA BULLET'),
          _Leaderboard(data.crazyhouse, ExoChessIcons.h_square, 'CRAZYHOUSE'),
          _Leaderboard(data.chess960, ExoChessIcons.die_six, 'CHESS 960'),
          _Leaderboard(data.kingOfThehill, ExoChessIcons.bullet, 'KING OF THE HILL'),
          _Leaderboard(data.threeCheck, ExoChessIcons.three_check, 'THREE CHECK'),
          _Leaderboard(data.atomic, ExoChessIcons.atom, 'ATOMIC'),
          _Leaderboard(data.horde, ExoChessIcons.horde, 'HORDE'),
          _Leaderboard(data.antichess, ExoChessIcons.antichess, 'ANTICHESS'),
          _Leaderboard(data.racingKings, ExoChessIcons.racing_kings, 'RACING KINGS'),
        ];

        return SafeArea(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = math.min(3, (constraints.maxWidth / 300).floor());
                return LayoutGrid(
                  columnSizes: List.generate(crossAxisCount, (_) => 1.fr),
                  rowSizes: List.generate((list.length / crossAxisCount).ceil(), (_) => auto),
                  children: list,
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => const Center(child: Text('Could not load leaderboard.')),
    );
  }
}

/// A List Tile for the Leaderboard
///
/// Optionaly Provide the [perfIcon] for the Variant of the List
class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({required this.user, this.perfIcon});
  final LeaderboardUser user;
  final IconData? perfIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _handleTap(context),
      leading: perfIcon != null ? Icon(perfIcon) : null,
      title: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: UserFullNameWidget(user: user.lightUser),
      ),
      trailing: perfIcon != null
          ? _Progress(user.rating, user.progress)
          : Text(user.rating.toString()),
    );
  }

  void _handleTap(BuildContext context) {
    Navigator.of(context).push(UserOrProfileScreen.buildRoute(context, user.lightUser));
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.rating, this.progress);
  final int progress;
  final int rating;

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return Text(rating.toString(), style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold));
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rating.toString(), 
          maxLines: 1, 
          style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Icon(
          progress > 0 ? ExoChessIcons.arrow_full_upperright : ExoChessIcons.arrow_full_lowerright,
          size: 14,
          color: progress > 0 ? Colors.green : const Color(0xFFD71921),
        ),
        Text(
          progress.abs().toString(),
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'SpaceMono',
            fontWeight: FontWeight.bold,
            color: progress > 0 ? Colors.green : const Color(0xFFD71921),
          ),
        ),
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard(this.userList, this.iconData, this.title);
  final List<LeaderboardUser> userList;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListSection(
        hasLeading: false,
        header: Row(
          children: [
            Icon(iconData, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12.0),
            Text(
              title.toUpperCase(),
              style: const TextStyle(fontFamily: 'NDot', fontSize: 16),
            ),
          ],
        ),
        children: userList.map((user) => LeaderboardListTile(user: user)).toList(),
      ),
    );
  }
}
