import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/notifications/notification_service.dart';
import 'package:chessigma_mobile/src/model/notifications/notifications.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_container.dart';

class NotificationDisplayMock extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notificationDisplayMock = NotificationDisplayMock();

  tearDown(() {
    reset(notificationDisplayMock);
  });

  group('NotificationService:', () {
    test('show local notification', () async {
      final container = await makeContainer(
        overrides: {
          notificationDisplayProvider: notificationDisplayProvider.overrideWith((_) => notificationDisplayMock),
        },
      );

      final notificationService = container.read(notificationServiceProvider);

      const fullId = GameFullId('9wlmxmibr9gh');
      const notification = CorresGameUpdateNotification(
        fullId,
        'It is your turn!',
        'Dr-Alaakour played a move',
      );

      when(
        () => notificationDisplayMock.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) => Future.value());

      await notificationService.show(notification);

      verify(
        () => notificationDisplayMock.show(
          id: notification.id,
          title: 'It is your turn!',
          body: 'Dr-Alaakour played a move',
          notificationDetails: any(named: 'notificationDetails'),
          payload: jsonEncode(notification.payload),
        ),
      ).called(1);
    });

    test('cancel notification', () async {
      final container = await makeContainer(
        overrides: {
          notificationDisplayProvider: notificationDisplayProvider.overrideWith((_) => notificationDisplayMock),
        },
      );

      final notificationService = container.read(notificationServiceProvider);

      when(() => notificationDisplayMock.cancel(id: any(named: 'id'))).thenAnswer((_) => Future.value());

      await notificationService.cancel(123);

      verify(() => notificationDisplayMock.cancel(id: 123)).called(1);
    });
  });
}
