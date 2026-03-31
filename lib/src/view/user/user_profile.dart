import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:exochess_mobile/l10n/l10n.dart';
import 'package:exochess_mobile/src/app_links.dart';
import 'package:exochess_mobile/src/constants.dart';
import 'package:exochess_mobile/src/model/auth/auth_controller.dart';
import 'package:exochess_mobile/src/model/user/profile.dart';
import 'package:exochess_mobile/src/model/user/user.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/duration.dart';
import 'package:exochess_mobile/src/utils/l10n.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/lichess_assets.dart';
import 'package:exochess_mobile/src/view/user/countries.dart';
import 'package:exochess_mobile/src/widgets/network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/cyberpunk.dart';

const _userNameStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w500);

class UserProfileWidget extends ConsumerWidget {
  const UserProfileWidget({required this.user, this.bioMaxLines = 15, this.margin});

  final User user;
  final EdgeInsetsGeometry? margin;

  final int bioMaxLines;
  static const bioStyle = TextStyle(fontStyle: FontStyle.italic);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authControllerProvider);
    final userFullName = user.profile?.realName != null
        ? Text(user.profile!.realName!, style: _userNameStyle)
        : null;

    return Padding(
      padding: margin ?? Styles.horizontalBodyPadding.add(Styles.sectionTopPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.tosViolation == true && authSession?.user.id != user.id)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFD71921)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          context.l10n.thisAccountViolatedTos.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFD71921),
                            fontFamily: 'SpaceMono',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (userFullName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    user.profile!.realName!.toUpperCase(),
                    style: const TextStyle(fontFamily: 'NDot', fontSize: 20),
                  ),
                ),
              if (user.profile?.bio != null)
                Linkify(
                  onOpen: (link) => onLinkifyOpen(context, link),
                  linkifiers: kExoChessLinkifiers,
                  text: user.profile!.bio!,
                  maxLines: bioMaxLines,
                  style: bioStyle.copyWith(fontSize: 14, height: 1.5),
                  overflow: TextOverflow.ellipsis,
                  linkStyle: Styles.linkStyle,
                ),
              const SizedBox(height: 16),
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.profile?.fideRating != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${context.l10n.xRating('FIDE')}: ${user.profile!.fideRating}'.toUpperCase()),
                      ),
                    if (user.profile?.uscfRating != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${context.l10n.xRating('USCF')}: ${user.profile!.uscfRating}'.toUpperCase()),
                      ),
                    if (user.profile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Location(profile: user.profile!),
                      ),
                    if (user.createdAt != null)
                      Text('${context.l10n.memberSince} ${DateFormat.yMMMMd().format(user.createdAt!)}'.toUpperCase()),
                    if (user.seenAt != null) ...[
                      const SizedBox(height: 4),
                      Text(context.l10n.lastSeenActive(relativeDate(context.l10n, user.seenAt!)).toUpperCase()),
                    ],
                    if (user.playTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.tpTimeSpentPlaying(
                          user.playTime!.total.toDaysHoursMinutes(AppLocalizations.of(context)),
                        ).toUpperCase(),
                      ),
                    ],
                  ],
                ),
              ),
              if (user.profile?.links != null) ...[
                const SizedBox(height: 24),
                Text(
                  context.l10n.socialMediaLinks.toUpperCase(),
                  style: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  children: [
                    for (final link in user.profile!.links!)
                      InkWell(
                        onTap: () => launchUrl(link.url),
                        child: Text(
                          (link.site?.title ?? link.url.toString()).toUpperCase(),
                          style: Styles.linkStyle.copyWith(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Location extends StatelessWidget {
  const Location({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (profile.location != null) ...[Text(profile.location!), const SizedBox(width: 5)],
        if (profile.country != null) ...[
          HttpNetworkImageWidget(
            lichessFlagSrc(profile.country!),
            errorBuilder: (_, _, _) => kEmptyWidget,
          ),
          const SizedBox(width: 5),
        ],
        if (countries[profile.country] != null) Text(countries[profile.country]!),
      ],
    );
  }
}
