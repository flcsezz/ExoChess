import 'package:flutter/material.dart';

abstract class FeedbackData {
  String label(BuildContext context);
  Color get color;
  String get symbol;
  IconData get icon;
}
