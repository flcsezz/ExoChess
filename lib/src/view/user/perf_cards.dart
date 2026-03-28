import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/constants.dart';
import 'package:chessigma_mobile/src/model/common/perf.dart';
import 'package:chessigma_mobile/src/model/user/user.dart';
import 'package:chessigma_mobile/src/styles/chessigma_icons.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/view/account/rating_pref_aware.dart';
import 'package:chessigma_mobile/src/view/puzzle/storm_dashboard.dart';
import 'package:chessigma_mobile/src/view/user/perf_stats_screen.dart';
import 'package:chessigma_mobile/src/widgets/rating.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/cyberpunk.dart';

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
            height: 106,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              scrollDirection: Axis.horizontal,
              itemCount: userPerfs.length,
              itemBuilder: (context, index) {
                final perf = userPerfs[index];
                final userPerf = user.perfs[perf]!;
                final bool isPerfWithoutStats = Perf.streak == perf;
                return SizedBox(
                  height: 100,
                  width: 100,
                  child: GlassCard(
                    padding: const EdgeInsets.all(6.0),
                    borderRadius: _kCardBorderRadius,
                    onTap: isPerfWithoutStats ? null : () => _handlePerfCardTap(context, perf),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(perf.shortTitle, style: TextStyle(color: textShade(context, 0.7))),
                        Icon(perf.icon, color: textShade(context, 0.6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            RatingWidget(
                              rating: userPerf.rating,
                              deviation: userPerf.ratingDeviation,
                              provisional: userPerf.provisional,
                              style: Styles.bold,
                            ),
                            const SizedBox(width: 3),
                            if (userPerf.progression != 0) ...[
                              Icon(
                                userPerf.progression > 0
                                    ? ChessigmaIcons.arrow_full_upperright
                                    : ChessigmaIcons.arrow_full_lowerright,
                                color: userPerf.progression > 0
                                    ? context.chessigmaColors.good
                                    : context.chessigmaColors.error,
                                size: 12,
                              ),
                              Flexible(
                                child: Text(
                                  userPerf.progression.abs().toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: userPerf.progression > 0
                                        ? context.chessigmaColors.good
                                        : context.chessigmaColors.error,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 10),
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
