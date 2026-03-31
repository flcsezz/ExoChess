import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/src/model/puzzle/puzzle_angle.dart';
import 'package:exochess_mobile/src/model/puzzle/puzzle_opening.dart';
import 'package:exochess_mobile/src/model/puzzle/puzzle_providers.dart';
import 'package:exochess_mobile/src/network/connectivity.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/puzzle/puzzle_screen.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';

final _openingsProvider =
    FutureProvider.autoDispose<(bool, IMap<String, int>, IList<PuzzleOpeningFamily>?)>((ref) async {
      final connectivity = await ref.watch(connectivityChangesProvider.future);
      final savedOpenings = await ref.watch(savedOpeningBatchesProvider.future);
      IList<PuzzleOpeningFamily>? onlineOpenings;
      try {
        onlineOpenings = await ref.watch(puzzleOpeningsProvider.future);
      } catch (e) {
        onlineOpenings = null;
      }
      return (connectivity.isOnline, savedOpenings, onlineOpenings);
    });

class OpeningThemeScreen extends StatelessWidget {
  const OpeningThemeScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const OpeningThemeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          context.l10n.puzzlePuzzlesByOpenings.toUpperCase(),
          style: const TextStyle(fontFamily: 'NDot', fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: const _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openings = ref.watch(_openingsProvider);
    return openings.when(
      data: (data) {
        final (isOnline, savedOpenings, onlineOpenings) = data;
        if (isOnline && onlineOpenings != null) {
          return ListView(
            children: [
              for (final openingFamily in onlineOpenings)
                _OpeningFamily(openingFamily: openingFamily, titleStyle: null),
            ],
          );
        } else {
          return ListView(
            children: [
              ListSection(
                children: [
                  for (final openingKey in savedOpenings.keys)
                    _OpeningTile(
                      name: openingKey.replaceAll('_', ' '),
                      openingKey: openingKey,
                      count: savedOpenings[openingKey]!,
                      titleStyle: null,
                    ),
                ],
              ),
            ],
          );
        }
      },
      error: (error, stack) {
        return const Center(child: Text('Could not load openings.'));
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class _OpeningFamily extends ConsumerWidget {
  const _OpeningFamily({required this.openingFamily, required this.titleStyle});

  final PuzzleOpeningFamily openingFamily;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: openingFamily.openings.isNotEmpty
          ? ExpansionTile(
              title: Text(
                openingFamily.name.toUpperCase(), 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${openingFamily.count} PUZZLES',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
              ),
              children: [
                ListSection(
                  children: [
                    _OpeningTile(
                      name: openingFamily.name,
                      openingKey: openingFamily.key,
                      count: openingFamily.count,
                      titleStyle: titleStyle,
                    ),
                    ...openingFamily.openings.map(
                      (opening) => _OpeningTile(
                        name: opening.name,
                        openingKey: opening.key,
                        count: opening.count,
                        titleStyle: titleStyle,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : ListTile(
              title: Text(
                openingFamily.name.toUpperCase(), 
                overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${openingFamily.count} PUZZLES',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
              ),
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(PuzzleScreen.buildRoute(context, angle: PuzzleOpening(openingFamily.key)));
              },
            ),
    );
  }
}

class _OpeningTile extends StatelessWidget {
  const _OpeningTile({
    required this.name,
    required this.openingKey,
    required this.count,
    this.titleStyle,
  });

  final String name;
  final String openingKey;
  final int count;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      title: Text(
        name.toUpperCase(), 
        overflow: TextOverflow.ellipsis, 
        style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 14),
      ),
      trailing: Text(
        '$count', 
        style: TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black38),
      ),
      onTap: () {
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(PuzzleScreen.buildRoute(context, angle: PuzzleOpening(openingKey)));
      },
    );
  }
}
