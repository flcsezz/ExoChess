import 'package:flutter/material.dart';
import 'package:chessigma_mobile/src/utils/l10n_context.dart';

enum MoveEvaluation {
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

  Color get color {
    switch (this) {
      case MoveEvaluation.brilliant:
        return const Color(0xFF26C2A3);
      case MoveEvaluation.great:
        return const Color(0xFF5C8BB0);
      case MoveEvaluation.best:
      case MoveEvaluation.excellent:
      case MoveEvaluation.good:
        return const Color(0xFF95B83C);
      case MoveEvaluation.book:
        return const Color(0xFFD5A47D);
      case MoveEvaluation.inaccuracy:
        return const Color(0xFFF0C15C);
      case MoveEvaluation.mistake:
        return const Color(0xFFE6912C);
      case MoveEvaluation.blunder:
        return const Color(0xFFB33430);
      case MoveEvaluation.forced:
        return const Color(0xFFB7B3B0);
    }
  }

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
    if (node.nags != null && node.nags!.isNotEmpty) {
      final eval = fromNag(node.nags!.first);
      if (eval != null) return eval;
    }

    // Check for judgment in server eval if available
    try {
      final serverEval = node.serverEval;
      if (serverEval != null && serverEval.judgment != null) {
        final name = serverEval.judgment!.name.toLowerCase();
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
      final Iterable<String>? comments = node.textComments;
      if (comments != null) {
        for (final comment in comments) {
          final lowercase = comment.toLowerCase();
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
