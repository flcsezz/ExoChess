import 'dart:convert';

import 'package:deep_pick/deep_pick.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chessigma_mobile/l10n/l10n.dart';
import 'package:chessigma_mobile/src/model/challenge/challenge.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/user/user.dart' show TemporaryBan;
import 'package:chessigma_mobile/src/utils/json.dart';
import 'package:chessigma_mobile/src/utils/l10n.dart' show relativeDate;
import 'package:meta/meta.dart';

/// Local Notifications
///////////////////////

/// A notification shown to the user from the platform's notification system.
@immutable
sealed class LocalNotification {
  const LocalNotification();

  /// The unique identifier of the notification.
  int get id;

  /// The channel identifier of the notification.
  ///
  /// Corresponds to [AndroidNotificationDetails.channelId] for android and
  /// [DarwinNotificationDetails.threadIdentifier] for iOS.
  ///
  /// It must match the channel identifier of the notification details.
  String get channelId;

  /// The localized title of the notification.
  String title(AppLocalizations l10n);

  /// The localized body of the notification.
  String? body(AppLocalizations l10n);

  /// The payload of the notification.
  ///
  /// Implementations must not override this getter, but [_concretePayload] instead.
  ///
  /// See [LocalNotification.fromJson] where the [channelId] is used to determine the
  /// concrete type of the notification, to be able to deserialize it.
  Map<String, dynamic> get payload => {'channel': channelId, ..._concretePayload};

  /// The actual payload of the notification.
  ///
  /// Will be merged with the channel:[channelId] entry to form the final payload.
  Map<String, dynamic> get _concretePayload;

  /// The localized details of the notification for each platform.
  NotificationDetails details(AppLocalizations l10n);

  /// Retrives a local notification from a JSON payload.
  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    final channel = json['channel'] as String;
    switch (channel) {
      case 'corresGameUpdate':
        return CorresGameUpdateNotification.fromJson(json);
      case 'challenge':
        return ChallengeNotification.fromJson(json);
      case 'playban':
        return PlaybanNotification.fromJson(json);
      case 'newMessage':
        return NewMessageNotification.fromJson(json);
      case 'challengeAccept':
        return ChallengeAcceptedNotification.fromJson(json);
      case 'challengeCreate':
        return ChallengeCreatedNotification.fromJson(json);
      case 'announce':
        return AnnounceNotification.fromJson(json);
      default:
        throw ArgumentError('Unknown notification channel: $channel');
    }
  }
}

/// A notification show to the user when they are banned temporarily from playing.
class PlaybanNotification extends LocalNotification {
  const PlaybanNotification(this.playban);

  final TemporaryBan playban;

  factory PlaybanNotification.fromJson(Map<String, dynamic> json) {
    final p = pick(json).required();
    final playban = TemporaryBan(
      date: p('date').asDateTimeFromMillisecondsOrThrow(),
      duration: p('minutes').asDurationFromMinutesOrThrow(),
    );
    return PlaybanNotification(playban);
  }

  @override
  String get channelId => 'playban';

  @override
  int get id => playban.date.toIso8601String().hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'minutes': playban.duration.inMinutes,
    'date': playban.date.millisecondsSinceEpoch,
  };

  @override
  String title(AppLocalizations l10n) => l10n.sorry;

  @override
  String body(AppLocalizations l10n) => l10n.weHadToTimeYouOutForAWhile;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      'playban',
      importance: Importance.max,
      priority: Priority.max,
      autoCancel: false,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a new message in a private conversation.
///
/// This notification is shown when a new message is received in a private conversation.
class NewMessageNotification extends LocalNotification {
  const NewMessageNotification(this.conversationId, String title, String message)
    : _title = title,
      _message = message;

  final UserId conversationId;
  final String _title;
  final String _message;

  factory NewMessageNotification.fromJson(Map<String, dynamic> json) {
    final conversationId = UserId.fromJson(json['conversationId'] as String);
    final title = json['title'] as String;
    final message = json['message'] as String;
    return NewMessageNotification(conversationId, title, message);
  }

  @override
  String get channelId => 'newMessage';

  @override
  int get id => conversationId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'conversationId': conversationId.toJson(),
    'title': _title,
    'message': _message,
  };

  @override
  String title(AppLocalizations l10n) => _title;

  @override
  String body(AppLocalizations _) => _message;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyInboxMsg,
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a correspondence game update.
class CorresGameUpdateNotification extends LocalNotification {
  const CorresGameUpdateNotification(this.fullId, String title, String body)
    : _title = title,
      _body = body;

  final GameFullId fullId;

  final String _title;
  final String _body;

  factory CorresGameUpdateNotification.fromJson(Map<String, dynamic> json) {
    final gameId = GameFullId.fromJson(json['fullId'] as String);
    final title = json['title'] as String;
    final body = json['body'] as String;
    return CorresGameUpdateNotification(gameId, title, body);
  }

  @override
  String get channelId => 'corresGameUpdate';

  @override
  int get id => fullId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'fullId': fullId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a challenge acceptance.
class ChallengeAcceptedNotification extends LocalNotification {
  const ChallengeAcceptedNotification(this.fullId, String title, String body)
    : _title = title,
      _body = body;

  final GameFullId fullId;

  final String _title;
  final String _body;

  factory ChallengeAcceptedNotification.fromJson(Map<String, dynamic> json) {
    final gameId = GameFullId.fromJson(json['fullId'] as String);
    final title = json['title'] as String;
    final body = json['body'] as String;
    return ChallengeAcceptedNotification(gameId, title, body);
  }

  @override
  String get channelId => 'challengeAccept';

  @override
  int get id => fullId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'fullId': fullId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a challenge creation.
class ChallengeCreatedNotification extends LocalNotification {
  const ChallengeCreatedNotification(this.challengeId, String title, String body)
    : _title = title,
      _body = body;

  final ChallengeId challengeId;

  final String _title;
  final String _body;

  factory ChallengeCreatedNotification.fromJson(Map<String, dynamic> json) {
    final challengeId = ChallengeId.fromJson(json['challengeId'] as String);
    final title = json['title'] as String;
    final body = json['body'] as String;
    return ChallengeCreatedNotification(challengeId, title, body);
  }

  @override
  String get channelId => 'challengeAccept';

  @override
  int get id => challengeId.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {
    'challengeId': challengeId.toJson(),
    'title': _title,
    'body': _body,
  };

  @override
  String title(_) => _title;

  @override
  String? body(_) => _body;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyGameEvent,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      autoCancel: true,
    ),
    iOS: DarwinNotificationDetails(threadIdentifier: channelId),
  );
}

/// A notification for a server-wide announcement.
class AnnounceNotification extends LocalNotification {
  const AnnounceNotification(this.message, {this.date});

  final String message;

  /// Optional date shown as a relative time in the notification body.
  final DateTime? date;

  static final int notificationId = 'announce'.hashCode;

  static const _channelId = 'announce';

  static const dismissActionId = 'dismiss';

  static const darwinCategoryId = 'announce-notification';

  factory AnnounceNotification.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    return AnnounceNotification(
      json['message'] as String,
      date: dateStr != null ? DateTime.parse(dateStr) : null,
    );
  }

  static DarwinNotificationCategory darwinCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinCategoryId,
        actions: [
          DarwinNotificationAction.plain(dismissActionId, l10n.mobileCustomizeHomeTipDismiss),
        ],
      );

  @override
  int get id => notificationId;

  @override
  String get channelId => _channelId;

  @override
  Map<String, dynamic> get _concretePayload => {
    'message': message,
    if (date != null) 'date': date!.toIso8601String(),
  };

  @override
  String title(AppLocalizations _) => message;

  @override
  String? body(AppLocalizations l10n) => date != null ? relativeDate(l10n, date!) : null;

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Lichess Announcements',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          dismissActionId,
          l10n.mobileCustomizeHomeTipDismiss,
          showsUserInterface: false,
        ),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      threadIdentifier: _channelId,
      categoryIdentifier: darwinCategoryId,
    ),
  );
}

/// A notification for a received challenge.
class ChallengeNotification extends LocalNotification {
  const ChallengeNotification(this.challenge);

  final Challenge challenge;

  factory ChallengeNotification.fromJson(Map<String, dynamic> json) {
    final challenge = Challenge.fromJson(json['challenge'] as Map<String, dynamic>);
    return ChallengeNotification(challenge);
  }

  @override
  String get channelId => 'challenge';

  @override
  int get id => challenge.id.value.hashCode;

  @override
  Map<String, dynamic> get _concretePayload => {'challenge': challenge.toJson()};

  @override
  String title(AppLocalizations _) => '${challenge.challenger!.user.name} challenges you!';

  @override
  String body(AppLocalizations l10n) => challenge.description(l10n);

  @override
  NotificationDetails details(AppLocalizations l10n) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      l10n.preferencesNotifyChallenge,
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: false,
      actions: <AndroidNotificationAction>[
        if (challenge.variant.isPlaySupported)
          AndroidNotificationAction(
            'accept',
            l10n.accept,
            icon: const DrawableResourceAndroidBitmap('tick'),
            showsUserInterface: true,
            contextual: true,
          ),
        AndroidNotificationAction(
          'decline',
          l10n.decline,
          icon: const DrawableResourceAndroidBitmap('cross'),
          showsUserInterface: true,
          contextual: true,
        ),
      ],
    ),
    iOS: DarwinNotificationDetails(
      threadIdentifier: channelId,
      categoryIdentifier: challenge.variant.isPlaySupported
          ? darwinPlayableVariantCategoryId
          : darwinUnplayableVariantCategoryId,
    ),
  );

  static const darwinPlayableVariantCategoryId = 'challenge-notification-playable-variant';

  static const darwinUnplayableVariantCategoryId = 'challenge-notification-unplayable-variant';

  static DarwinNotificationCategory darwinPlayableVariantCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinPlayableVariantCategoryId,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'accept',
            l10n.accept,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            'decline',
            l10n.decline,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      );

  static DarwinNotificationCategory darwinUnplayableVariantCategory(AppLocalizations l10n) =>
      DarwinNotificationCategory(
        darwinUnplayableVariantCategoryId,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'decline',
            l10n.decline,
            options: <DarwinNotificationActionOption>{DarwinNotificationActionOption.foreground},
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      );
}
