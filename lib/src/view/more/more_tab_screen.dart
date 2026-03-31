import 'package:dartchess/dartchess.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:exochess_mobile/src/model/common/chess.dart';
import 'package:exochess_mobile/src/model/onboarding/onboarding_preferences.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/view/account/account_drawer.dart';
import 'package:exochess_mobile/src/view/broadcast/broadcast_list_screen.dart';
import 'package:exochess_mobile/src/view/challenge/challenge_requests_screen.dart';
import 'package:exochess_mobile/src/view/clock/clock_tool_screen.dart';
import 'package:exochess_mobile/src/view/explorer/opening_explorer_screen.dart';
import 'package:exochess_mobile/src/view/tv/tv_channels_screen.dart';
import 'package:exochess_mobile/src/widgets/misc.dart';
import 'package:exochess_mobile/src/widgets/platform.dart';
import 'package:exochess_mobile/src/widgets/vector_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class MoreTabScreen extends ConsumerWidget {
  const MoreTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(context.l10n.more.toUpperCase(), style: const TextStyle(fontFamily: 'NDot', fontSize: 20)),
        centerTitle: true,
        leading: const SettingsIconButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VectorHeader(
              title: context.l10n.openingExplorer.toUpperCase(),
              subtitle: 'MASTER THE OPENINGS WITH LICHESS DB',
              icon: Symbols.explore,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  OpeningExplorerScreen.buildRoute(
                    context,
                    const AnalysisOptions.standalone(
                      variant: Variant.standard,
                      orientation: Side.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SmallVectorCard(
                    title: 'CLOCK',
                    subtitle: 'OTB TIMER',
                    icon: Symbols.hourglass_bottom,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(ClockToolScreen.buildRoute(context));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SmallVectorCard(
                    title: 'TOUR',
                    subtitle: 'APP ONBOARDING',
                    icon: Symbols.tour,
                    onTap: () {
                      ref.read(onboardingPreferencesProvider.notifier).reset();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SmallVectorCard(
                    title: 'BROADCAST',
                    subtitle: 'LIVE TOURNAMENTS',
                    icon: Symbols.satellite_alt,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(BroadcastListScreen.buildRoute(context));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SmallVectorCard(
                    title: 'TV',
                    subtitle: 'WATCH MASTERS',
                    icon: Symbols.live_tv,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(TvChannelsScreen.buildRoute(context));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VectorHeader(
              title: 'CHALLENGES',
              subtitle: 'PLAY YOUR FRIENDS',
              icon: Symbols.swords,
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(ChallengeRequestsScreen.buildRoute(context));
              },
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ExoChessMessage(
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



