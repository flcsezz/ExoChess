import 'package:exochess_mobile/src/model/common/feedback_data.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:flutter/material.dart';

enum MoveEvaluation implements FeedbackData {
  brilliant,
  great,
  best,
  excellent,
  good,
  book,
  inaccuracy,
  mistake,
  blunder,
  forced;

  @override
  String label(BuildContext context) {
    switch (this) {
      case MoveEvaluation.brilliant:
        return context.l10n.studyBrilliantMove;
      case MoveEvaluation.great:
        return 'Great Move';
      case MoveEvaluation.best:
        return context.l10n.puzzleBestMove;
      case MoveEvaluation.excellent:
        return 'Excellent';
      case MoveEvaluation.good:
        return context.l10n.puzzleGoodMove;
      case MoveEvaluation.book:
        return 'Book';
      case MoveEvaluation.inaccuracy:
        return context.l10n.inaccuracy;
      case MoveEvaluation.mistake:
        return context.l10n.mistake;
      case MoveEvaluation.blunder:
        return context.l10n.blunder;
      case MoveEvaluation.forced:
        return 'Forced';
    }
  }

  @override
  Color get color {
    switch (this) {
      case MoveEvaluation.brilliant:
        return const Color(0xFF00F2FF); // Luminous Cyan
      case MoveEvaluation.great:
        return const Color(0xFF00FF88); // Luminous Green
      case MoveEvaluation.best:
        return const Color(0xFFAAFF00); // Luminous Lime
      case MoveEvaluation.excellent:
        return const Color(0xFF00AAFF); // Luminous Blue
      case MoveEvaluation.good:
        return const Color(0xFFAAFF00); // Luminous Lime
      case MoveEvaluation.book:
        return const Color(0xFFD5A47D);
      case MoveEvaluation.inaccuracy:
        return const Color(0xFFFFE600); // Luminous Yellow
      case MoveEvaluation.mistake:
        return const Color(0xFFFF9500); // Luminous Orange
      case MoveEvaluation.blunder:
        return const Color(0xFFFF0055); // Luminous Pink/Red
      case MoveEvaluation.forced:
        return const Color(0xFFB7B3B0);
    }
  }

  @override
  IconData get icon {
    switch (this) {
      case MoveEvaluation.brilliant:
        return Icons.auto_awesome;
      case MoveEvaluation.great:
        return Icons.stars;
      case MoveEvaluation.best:
        return Icons.verified;
      case MoveEvaluation.excellent:
        return Icons.thumb_up;
      case MoveEvaluation.good:
        return Icons.check_circle;
      case MoveEvaluation.book:
        return Icons.menu_book;
      case MoveEvaluation.inaccuracy:
        return Icons.help_outline;
      case MoveEvaluation.mistake:
        return Icons.warning_amber;
      case MoveEvaluation.blunder:
        return Icons.dangerous;
      case MoveEvaluation.forced:
        return Icons.link;
    }
  }

  @override
  String get symbol {
    switch (this) {
      case MoveEvaluation.brilliant:
        return '!!';
      case MoveEvaluation.great:
        return '!';
      case MoveEvaluation.best:
        return '★';
      case MoveEvaluation.excellent:
        return '!!';
      case MoveEvaluation.good:
        return '!';
      case MoveEvaluation.book:
        return '📖';
      case MoveEvaluation.inaccuracy:
        return '?!';
      case MoveEvaluation.mistake:
        return '?';
      case MoveEvaluation.blunder:
        return '??';
      case MoveEvaluation.forced:
        return '➡';
    }
  }

  static MoveEvaluation? fromNag(int nag) {
    switch (nag) {
      case 1:
        return MoveEvaluation.great;
      case 2:
        return MoveEvaluation.mistake;
      case 3:
        return MoveEvaluation.brilliant;
      case 4:
        return MoveEvaluation.blunder;
      case 5:
        return MoveEvaluation.good;
      case 6:
        return MoveEvaluation.inaccuracy;
      default:
        return null;
    }
  }

  static MoveEvaluation? fromAnalysis(dynamic node) {
    if (node.nags is Iterable && (node.nags as Iterable).isNotEmpty) {
      final eval = fromNag((node.nags as Iterable).first as int);
      if (eval != null) return eval;
    }
    
    // Check for judgment in server eval if available
    try {
      final serverEval = node.serverEval;
      if (serverEval != null && serverEval.judgment != null) {
        final String name = (serverEval.judgment!.name as String).toLowerCase();
        if (name.contains('brilliant')) return MoveEvaluation.brilliant;
        if (name.contains('great')) return MoveEvaluation.great;
        if (name.contains('best')) return MoveEvaluation.best;
        if (name.contains('excellent')) return MoveEvaluation.excellent;
        if (name.contains('good')) return MoveEvaluation.good;
        if (name.contains('inaccuracy')) return MoveEvaluation.inaccuracy;
        if (name.contains('mistake')) return MoveEvaluation.mistake;
        if (name.contains('blunder')) return MoveEvaluation.blunder;
        if (name.contains('forced')) return MoveEvaluation.forced;
        if (name.contains('book')) return MoveEvaluation.book;
      }
    } catch (_) {
      // Ignore if serverEval is not available on the object
    }

    // Check text comments for common labels
    try {
      final Iterable<String>? comments = node.textComments as Iterable<String>?;
      if (comments != null) {
        for (final comment in comments) {
          final String lowercase = comment.toLowerCase();
          if (lowercase.contains('brilliant')) return MoveEvaluation.brilliant;
          if (lowercase.contains('great move')) return MoveEvaluation.great;
          if (lowercase.contains('best move')) return MoveEvaluation.best;
          if (lowercase.contains('excellent')) return MoveEvaluation.excellent;
          if (lowercase.contains('inaccuracy')) return MoveEvaluation.inaccuracy;
          if (lowercase.contains('mistake')) return MoveEvaluation.mistake;
          if (lowercase.contains('missed win')) return MoveEvaluation.mistake;
          if (lowercase.contains('blunder')) return MoveEvaluation.blunder;
        }
      }
    } catch (_) {
      // Ignore if textComments is not available
    }

    return null;
  }
}
