import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/model/analysis/move_evaluation.dart';

class MoveFeedbackWidget extends StatefulWidget {
  const MoveFeedbackWidget({
    required this.evaluation,
    required this.square,
    required this.boardSize,
    required this.orientation,
    super.key,
  });

  final MoveEvaluation evaluation;
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
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_controller);

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

    // Adjust for orientation
    final double left = widget.orientation == Side.white
        ? file * squareSize
        : (7 - file) * squareSize;
    final double bottom = widget.orientation == Side.white
        ? rank * squareSize
        : (7 - rank) * squareSize;

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
              // Evaluation Icon
              Align(
                alignment: Alignment.topRight,
                child: Transform.translate(
                  offset: const Offset(5, -5),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: widget.evaluation.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.evaluation.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Feedback Label
              Positioned(
                top: -20,
                left: -20,
                right: -20,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.evaluation.label(context),
                          style: TextStyle(
                            color: widget.evaluation.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
