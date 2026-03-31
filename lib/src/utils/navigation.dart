import 'package:flutter/material.dart';
import 'package:exochess_mobile/src/widgets/background.dart';

/// A page route that always builds the same screen widget.
///
/// This is useful to inspect new screens being pushed to the Navigator in tests.
abstract class ScreenRoute<T extends Object?> extends PageRoute<T> {
  /// The widget that this page route always builds.
  Widget get screen;
}

/// A [MaterialPageRoute] that always builds the same screen widget.
///
/// This route wraps the [screen] with a [FullScreenBackground] to ensure that the background
/// is always filled with the configured app's background color or image.
class MaterialScreenRoute<T extends Object?> extends PageRoute<T>
    implements ScreenRoute<T> {
  MaterialScreenRoute({
    required this.screen,
    super.settings,
    super.fullscreenDialog,
    this.overrideTransitionDuration,
  }) : super();

  @override
  final Widget screen;

  final Duration? overrideTransitionDuration;

  @override
  Duration get transitionDuration => overrideTransitionDuration ?? const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FullScreenBackground(child: screen);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

/// Builds a new route for the [screen] based on the platform.
///
/// This route wraps the [screen] with a [FullScreenBackground] to ensure that the background
/// is always filled with the configured app's background color or image.
///
/// It will return a [MaterialScreenRoute] on Android and a [CupertinoScreenRoute] on iOS.
Route<T> buildScreenRoute<T>(
  BuildContext context, {
  required Widget screen,
  bool fullscreenDialog = false,
  RouteSettings? settings,
  Duration? transitionDuration,
}) {
  return MaterialScreenRoute<T>(
    screen: screen,
    fullscreenDialog: fullscreenDialog,
    settings: settings,
    overrideTransitionDuration: transitionDuration,
  );
}
