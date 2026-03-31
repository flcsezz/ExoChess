import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/study/study.dart';
import 'package:exochess_mobile/src/model/study/study_filter.dart';
import 'package:exochess_mobile/src/model/study/study_repository.dart';
import 'package:exochess_mobile/src/network/connectivity.dart';
import 'package:exochess_mobile/src/network/http.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/tab_scaffold.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/view/account/account_drawer.dart';
import 'package:exochess_mobile/src/view/common/lichess_browser_screen.dart';
import 'package:exochess_mobile/src/view/coordinate_training/coordinate_training_screen.dart';
import 'package:exochess_mobile/src/view/study/study_list_screen.dart';
import 'package:exochess_mobile/src/widgets/list.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:exochess_mobile/src/widgets/vector_cards.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

final _hotStudiesProvider = FutureProvider.autoDispose<IList<StudyPageItem>>((Ref ref) {
  return ref.withClientCacheFor(
    (client) => StudyRepository(ref, client)
        .getStudies(category: StudyCategory.all, order: StudyListOrder.hot)
        .then((value) => value.studies),
    const Duration(hours: 6),
  );
});

final _myStudiesLengthProvider = FutureProvider.autoDispose<int>((Ref ref) {
  final authUser = ref.watch(authControllerProvider);
  if (authUser == null) return Future.value(0);

  return ref.withClientCacheFor(
    (client) => StudyRepository(ref, client)
        .getStudies(category: StudyCategory.mine, order: StudyListOrder.updated)
        .then((value) => value.studies.length),
    const Duration(hours: 6),
  );
});

final _myFavoriteStudiesLengthProvider = FutureProvider.autoDispose<int>((Ref ref) {
  final authUser = ref.watch(authControllerProvider);
  if (authUser == null) return Future.value(0);

  return ref.withClientCacheFor(
    (client) => StudyRepository(ref, client)
        .getStudies(category: StudyCategory.likes, order: StudyListOrder.updated)
        .then((value) => value.studies.length),
    const Duration(hours: 6),
  );
});

class LearnTabScreen extends ConsumerWidget {
  const LearnTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) {
          ref.read(currentBottomTabProvider.notifier).state = BottomTab.home;
        }
      },
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          leading: const SettingsIconButton(),
          title: Text(context.l10n.learnMenu.toUpperCase(), style: const TextStyle(fontFamily: 'NDot', fontSize: 20)),
          centerTitle: true,
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityChangesProvider).value?.isOnline ?? false;
    final authUser = ref.watch(authControllerProvider);
    final haveIStudies = authUser != null && (ref.watch(_myStudiesLengthProvider).value ?? 0) > 0;
    final haveIFavoriteStudies =
        authUser != null && (ref.watch(_myFavoriteStudiesLengthProvider).value ?? 0) > 0;

    return ListView(
      controller: learnScrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(bottom: 12)),
          child: VectorHeader(
            title: 'CHESS BASICS',
            subtitle: 'LEARN HOW TO PLAY',
            icon: Symbols.school,
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                LichessBrowserScreen.buildRoute(
                  context,
                  url: 'https://lichess.org/learn',
                  title: 'CHESS BASICS',
                ),
              );
            },
          ),
        ),
        Padding(
          padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(bottom: 12)),
          child: Row(
            children: [
              Expanded(
                child: SmallVectorCard(
                  title: 'PRACTICE',
                  subtitle: 'MASTER TACTICS',
                  icon: Symbols.exercise,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      LichessBrowserScreen.buildRoute(
                        context,
                        url: 'https://lichess.org/practice',
                        title: 'PRACTICE',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SmallVectorCard(
                  title: 'COORDS',
                  subtitle: 'TRAIN VISION',
                  icon: Symbols.where_to_vote,
                  onTap: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push(CoordinateTrainingScreen.buildRoute(context)),
                ),
              ),
            ],
          ),
        ),
        if (isOnline) ...[
          ListSection(
            header: Text(context.l10n.studyMenu.toUpperCase(), style: const TextStyle(fontFamily: 'NDot', fontSize: 18)),
            onHeaderTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).push(StudyListScreen.buildRoute(context)),
            hasLeading: true,
            children: [
              ...(switch (ref.watch(_hotStudiesProvider)) {
                AsyncData(:final value) =>
                  value
                      .take(5)
                      .map((study) => StudyListItem(study: study, titleMaxLines: 1))
                      .toList(growable: false),
                _ => [],
              }),
            ],
          ),
          if (haveIStudies || haveIFavoriteStudies)
            ListSection(
              hasLeading: true,
              margin: Styles.horizontalBodyPadding.add(Styles.sectionBottomPadding),
              children: [
                if (haveIStudies)
                  ListTile(
                    leading: const Icon(Symbols.local_library),
                    title: Text(context.l10n.studyMyStudies.toUpperCase(), style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold)),
                    onTap: isOnline
                        ? () => Navigator.of(context).push(
                            StudyListScreen.buildRoute(
                              context,
                              initialCategory: StudyCategory.mine,
                            ),
                          )
                        : null,
                  ),
                if (haveIFavoriteStudies)
                  ListTile(
                    leading: const Icon(Symbols.favorite),
                    title: Text(context.l10n.studyMyFavoriteStudies.toUpperCase(), style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold)),
                    onTap: isOnline
                        ? () => Navigator.of(context).push(
                            StudyListScreen.buildRoute(
                              context,
                              initialCategory: StudyCategory.likes,
                            ),
                          )
                        : null,
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
