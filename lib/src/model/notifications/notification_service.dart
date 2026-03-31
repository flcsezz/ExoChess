import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exochess_mobile/l10n/l10n.dart';
import 'package:exochess_mobile/src/localizations.dart';
import 'package:exochess_mobile/src/model/notifications/notifications.dart';
import 'package:logging/logging.dart';

final _logger = Logger('NotificationService');

/// A provider instance of the [FlutterLocalNotificationsPlugin].
final notificationDisplayProvider = Provider<FlutterLocalNotificationsPlugin>(
  (Ref _) => FlutterLocalNotificationsPlugin(),
);

/// A provider instance of the [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((Ref ref) {
  final service = NotificationService(ref);

  ref.onDispose(() => service._dispose());

  return service;
});

/// A [NotificationResponse] and the associated [LocalNotification].
typedef ParsedLocalNotification = (NotificationResponse response, LocalNotification notification);

/// A service that manages notifications.
///
/// This service is responsible for showing local notifications.
class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;

  /// The stream controller for notification responses.
  static final StreamController<ParsedLocalNotification> _responseStreamController =
      StreamController.broadcast();

  /// The stream of notification responses.
  ///
  /// A notification response is dispatched when a notification has been interacted with.
  static Stream<ParsedLocalNotification> get responseStream => _responseStreamController.stream;

  /// The stream subscription for notification responses.
  StreamSubscription<NotificationResponse>? _responseStreamSubscription;

  AppLocalizations get _l10n => _ref.read(localizationsProvider).strings;

  FlutterLocalNotificationsPlugin get _notificationDisplay =>
      _ref.read(notificationDisplayProvider);

  /// Starts the notification service.
  ///
  /// This method should be called once the app is ready to receive notifications.
  Future<void> start() async {
    if (defaultTargetPlatform == TargetPlatform.linux) return;
  }

  /// Shows a notification.
  Future<int> show(LocalNotification notification) async {
    final id = notification.id;
    final payload = jsonEncode(notification.payload);

    await _notificationDisplay.show(
      id: id,
      title: notification.title(_l10n),
      body: notification.body(_l10n),
      notificationDetails: notification.details(_l10n),
      payload: payload,
    );
    _logger.info(
      'Show local notification: ($id | ${notification.title}) ${notification.body} (Payload: ${notification.payload})',
    );

    return id;
  }

  /// Cancels/removes a notification.
  Future<void> cancel(int id) {
    _logger.info('canceled notification id: [$id]');
    return _notificationDisplay.cancel(id: id);
  }

  void _dispose() {
    _responseStreamSubscription?.cancel();
  }

  /// Function called by the notification plugin when a notification has been tapped on.
  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    _logger.fine('received local notification ${response.id} response in foreground.');

    final rawPayload = response.payload;

    if (rawPayload == null) {
      _logger.warning('Received a notification response with no payload.');
      return;
    }

    final json = jsonDecode(rawPayload) as Map<String, dynamic>;
    final notification = LocalNotification.fromJson(json);

    _responseStreamController.add((response, notification));
  }

  /// Register the device for push notifications.
  Future<bool> registerDevice() async {
    return false;
  }

  /// Unregister the device from push notifications.
  Future<void> unregister() async {}
}
