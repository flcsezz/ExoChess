import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/account/account_repository.dart';
import 'package:chessigma_mobile/src/model/auth/auth_controller.dart';
import 'package:chessigma_mobile/src/model/common/id.dart';
import 'package:chessigma_mobile/src/model/notifications/notification_service.dart';
import 'package:chessigma_mobile/src/model/notifications/notifications.dart'
    show LocalNotification;

/// A provider for [AccountService].
final accountServiceProvider = Provider<AccountService>((Ref ref) {
  final service = AccountService(ref);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
}, name: 'AccountServiceProvider');

class AccountService {
  AccountService(this._ref);

  StreamSubscription<(NotificationResponse, LocalNotification)>? _notificationResponseSubscription;

  /// Stream of bookmark changes for the current user.
  final StreamController<(GameId, bool)> _bookmarkChangesController = StreamController.broadcast();

  /// Stream of bookmark changes for the current user.
  Stream<(GameId, bool)> get bookmarkChanges => _bookmarkChangesController.stream;

  final Ref _ref;

  void start() {
    _notificationResponseSubscription = NotificationService.responseStream.listen((data) {
      // Handle other notifications if any
    });
  }

  void dispose() {
    _notificationResponseSubscription?.cancel();
    _bookmarkChangesController.close();
  }

  Future<void> setGameBookmark(GameId id, {required bool bookmark}) async {
    final authUser = _ref.read(authControllerProvider);
    if (authUser == null) return;

    await _ref.read(accountRepositoryProvider).bookmark(id, bookmark: bookmark);

    _bookmarkChangesController.add((id, bookmark));
  }
}
