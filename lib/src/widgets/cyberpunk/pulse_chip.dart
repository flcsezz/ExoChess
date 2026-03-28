import 'package:flutter/material.dart';

class PulseChip extends StatefulWidget {
  const PulseChip({
    super.key,
    required this.label,
    this.color = const Color(0xFF39FF14),
  });

  final String label;
  final Color color;

  @override
  State<PulseChip> createState() => _PulseChipState();
}

class _PulseChipState extends State<PulseChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1 * _animation.value),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.5 * _animation.value),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }
}
