import 'dart:convert';

import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exochess_mobile/src/model/analysis/analysis_controller.dart';
import 'package:exochess_mobile/src/model/common/chess.dart';
import 'package:exochess_mobile/src/model/common/id.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/utils/l10n_context.dart';
import 'package:exochess_mobile/src/utils/navigation.dart';
import 'package:exochess_mobile/src/view/analysis/analysis_screen.dart';
import 'package:exochess_mobile/src/view/analysis/pgn_games_list_screen.dart';
import 'package:exochess_mobile/src/widgets/feedback.dart';

class ImportPgnScreen extends StatelessWidget {
  const ImportPgnScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const ImportPgnScreen());
  }

  static void handleIncomingChessData(BuildContext context, String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    // 1. Try FEN
    try {
      final setup = Setup.parseFen(text);
      Position.setupPosition(Rule.chess, setup);
      const variant = Variant.standard;
      Navigator.of(context, rootNavigator: true).push(
        AnalysisScreen.buildRoute(
          context,
          AnalysisOptions.fen(
            id: const StringId('fen_import'),
            fen: text,
            variant: variant,
          ),
        ),
      );
      return;
    } catch (_) {}

    // 2. Try PGN parsing
    try {
      final games = PgnGame.parseMultiGamePgn(text);

      if (games.isEmpty) {
        showSnackBar(context, context.l10n.invalidPgn, type: SnackBarType.error);
        return;
      }

      if (games.length == 1) {
        final game = games.first;
        final rule = Rule.fromPgn(game.headers['Variant']);
        
        const orientation = Side.white;
        // Basic heuristic: if the PGN contains player names, we might want to flip the board,
        // but for a general import, white is the safest default.

        Navigator.of(context, rootNavigator: true).push(
          AnalysisScreen.buildRoute(
            context,
            AnalysisOptions.pgn(
              id: const StringId('pgn_import_single_game'),
              orientation: orientation,
              pgn: text,
              isComputerAnalysisAllowed: true,
              initialMoveCursor: game.moves.mainline().isEmpty ? 0 : 1,
              variant: rule != null ? Variant.fromRule(rule) : Variant.standard,
            ),
          ),
        );
      } else {
        Navigator.of(
          context,
          rootNavigator: true,
        ).push(PgnGamesListScreen.buildRoute(context, games.lock));
      }
    } catch (_) {
      showSnackBar(context, context.l10n.invalidPgn, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.importPgn)),
      body: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: Styles.bodySectionPadding,
              child: TextField(
                maxLines: 500,
                decoration: InputDecoration(
                  hintText: context.l10n.pasteThePgnStringHere,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _getClipboardData,
                    tooltip: 'Paste from clipboard',
                  ),
                ),
                readOnly: true,
                onTap: _getClipboardData,
              ),
            ),
          ),
          Padding(
            padding: Styles.bodySectionBottomPadding,
            child: FilledButton(
              onPressed: _pickPgnFile,
              child: Text(context.l10n.mobileOrImportPgnFile),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getClipboardData() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    if (!mounted) return;

    final text = data!.text!.trim();
    if (text.isEmpty) return;

    ImportPgnScreen.handleIncomingChessData(context, text);
  }

  Future<void> _pickPgnFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pgn'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final content = utf8.decode(result.files.single.bytes!);
        if (mounted) {
          ImportPgnScreen.handleIncomingChessData(context, content);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error loading file: $e', type: SnackBarType.error);
      }
    }
  }
}
