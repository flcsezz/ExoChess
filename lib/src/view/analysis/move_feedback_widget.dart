import 'package:exochess_mobile/src/model/common/feedback_data.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

class MoveFeedbackWidget extends StatefulWidget {
  const MoveFeedbackWidget({
    required this.evaluation,
    required this.square,
    required this.boardSize,
    required this.orientation,
    super.key,
  });

  final FeedbackData evaluation;
  final Square square;
  final double boardSize;
  final Side orientation;

  @override
  State<MoveFeedbackWidget> createState() => _MoveFeedbackWidgetState();
}

class _MoveFeedbackWidgetState extends State<MoveFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
    ]).animate(_controller);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(MoveFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.evaluation != widget.evaluation || oldWidget.square != widget.square) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final squareSize = widget.boardSize / 8;
    final squareIndex = widget.square;

    // Calculate file and rank (0-7)
    final int file = squareIndex % 8;
    final int rank = squareIndex ~/ 8;

    // Adjust for orientation to map logical square to physical screen metrics
    final bool isWhiteOrientation = widget.orientation == Side.white;
    final double left = isWhiteOrientation ? file * squareSize : (7 - file) * squareSize;
    final double bottom = isWhiteOrientation ? rank * squareSize : (7 - rank) * squareSize;

    final double physicalFile = isWhiteOrientation ? file.toDouble() : (7 - file).toDouble();
    final double physicalRank = isWhiteOrientation ? rank.toDouble() : (7 - rank).toDouble();

    // The badge floats at the top-right corner of the target square
    final double badgeSize = squareSize * 0.55;
    final double overlap = badgeSize * 0.35;

    // Flush the badge to the internal edges to prevent outside board clipping
    final double rightOffset = physicalFile == 7 ? 0 : -overlap;
    final double topOffset = physicalRank == 7 ? 0 : -overlap;

    // Labels needs to avoid edges so they aren't physically clipped.
    final bool isRightEdge = physicalFile >= 6;
    final bool isTopEdge = physicalRank >= 6;
    final bool isLeftEdge = physicalFile <= 1;

    final double? labelTop = isTopEdge ? null : -24.0;
    final double? labelBottom = isTopEdge ? -24.0 : null;

    // Adjust label horizontal position to prevent side clipping
    final double labelLeft = isLeftEdge ? -10.0 : -40.0;
    final double labelRight = isRightEdge ? -10.0 : -40.0;

    return Positioned(
      left: left,
      bottom: bottom,
      child: IgnorePointer(
        child: SizedBox(
          width: squareSize,
          height: squareSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: rightOffset,
                top: topOffset,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: widget.evaluation.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: widget.evaluation.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          widget.evaluation.icon,
                          color: Colors.white,
                          size: badgeSize * 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: labelTop,
                bottom: labelBottom,
                left: labelLeft,
                right: labelRight,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.evaluation.color.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          widget.evaluation.label(context).toUpperCase(),
                          style: TextStyle(
                            color: widget.evaluation.color,
                            fontSize: 9,
                            fontFamily: 'SpaceMono',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
