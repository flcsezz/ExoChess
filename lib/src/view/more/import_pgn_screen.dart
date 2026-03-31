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

  static void handlePgnText(BuildContext context, String text) {
    try {
      final games = PgnGame.parseMultiGamePgn(text);

      if (games.isEmpty) {
        showSnackBar(context, context.l10n.invalidPgn, type: .error);
        return;
      }

      if (games.length == 1) {
        final game = games.first;
        final rule = Rule.fromPgn(game.headers['Variant']);
        
        // Try to detect orientation if a username is provided (e.g. from external fetch)
        // Or if we can find a likely "user" in headers
        Side orientation = Side.white;
        final white = game.headers['White']?.toLowerCase() ?? '';
        final black = game.headers['Black']?.toLowerCase() ?? '';
        
        // This is a bit of a heuristic if we don't have a specific user context
        // in this static method, but we can check if one of the names looks like a "user"
        // In local PGN imports, we might not know who's who, so white is a safe default.

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
      showSnackBar(context, context.l10n.invalidPgn, type: .error);
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

    ImportPgnScreen.handlePgnText(context, text);
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
          ImportPgnScreen.handlePgnText(context, content);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error loading file: $e', type: SnackBarType.error);
      }
    }
  }
}
