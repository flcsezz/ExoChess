import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/constants.dart';
import 'package:exochess_mobile/src/model/common/perf.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/view/account/rating_pref_aware.dart';
import 'package:exochess_mobile/src/view/puzzle/storm_dashboard.dart';
import 'package:exochess_mobile/src/view/user/perf_stats_screen.dart';
import 'package:exochess_mobile/src/widgets/rating.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';

/// A widget that displays the performance cards of a user.
class PerfCards extends StatelessWidget {
  const PerfCards({required this.user, required this.isMe, this.padding, super.key});

  final User user;

  final bool isMe;

  final EdgeInsetsGeometry? padding;

  static const BorderRadius _kCardBorderRadius = BorderRadius.all(Radius.circular(6.0));

  @override
  Widget build(BuildContext context) {
    const puzzlePerfsSet = {Perf.puzzle, Perf.streak, Perf.storm};
    final List<Perf> gamePerfs = Perf.values
        .where((element) {
          if (puzzlePerfsSet.contains(element)) {
            return false;
          }
          final p = user.perfs[element];
          return p != null && p.numberOfGamesOrRuns > 0 && p.ratingDeviation < kClueLessDeviation;
        })
        .toList(growable: false);

    gamePerfs.sort(
      (p1, p2) =>
          user.perfs[p2]!.numberOfGamesOrRuns.compareTo(user.perfs[p1]!.numberOfGamesOrRuns),
    );

    final List<Perf> puzzlePerfs = Perf.values
        .where((element) {
          if (!puzzlePerfsSet.contains(element)) {
            return false;
          }
          final p = user.perfs[element];
          return p != null && p.numberOfGamesOrRuns > 0;
        })
        .toList(growable: false);

    puzzlePerfs.sort(
      (p1, p2) =>
          user.perfs[p2]!.numberOfGamesOrRuns.compareTo(user.perfs[p1]!.numberOfGamesOrRuns),
    );

    final userPerfs = [...gamePerfs, ...puzzlePerfs];

    if (userPerfs.isEmpty) {
      return const SizedBox.shrink();
    }

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: RatingPrefAware(
        child: Padding(
          padding: padding ?? Styles.bodySectionPadding,
          child: SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              scrollDirection: Axis.horizontal,
              itemCount: userPerfs.length,
              itemBuilder: (context, index) {
                final perf = userPerfs[index];
                final userPerf = user.perfs[perf]!;
                final bool isPerfWithoutStats = Perf.streak == perf;
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;

                return SizedBox(
                  width: 110,
                  child: Card(
                    child: InkWell(
                      onTap: isPerfWithoutStats ? null : () => _handlePerfCardTap(context, perf),
                      borderRadius: Styles.cardBorderRadius,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perf.shortTitle.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'SpaceMono',
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(perf.icon, size: 20, color: theme.colorScheme.primary),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                RatingWidget(
                                  rating: userPerf.rating,
                                  deviation: userPerf.ratingDeviation,
                                  provisional: userPerf.provisional,
                                  style: const TextStyle(
                                    fontFamily: 'SpaceMono',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (userPerf.progression != 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${userPerf.progression > 0 ? '+' : ''}${userPerf.progression}',
                                    style: TextStyle(
                                      color: userPerf.progression > 0
                                          ? Colors.green
                                          : const Color(0xFFD71921),
                                      fontSize: 10,
                                      fontFamily: 'SpaceMono',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePerfCardTap(BuildContext context, Perf perf) {
    Navigator.of(context).push(switch (perf) {
      Perf.storm => StormDashboardModal.buildRoute(context, user.lightUser),
      _ => PerfStatsScreen.buildRoute(context, user: user, perf: perf),
    });
  }
}
