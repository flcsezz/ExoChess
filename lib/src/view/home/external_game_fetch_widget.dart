import 'dart:convert';

import 'package:chessigma_mobile/src/model/common/chess.dart';
import 'package:chessigma_mobile/src/model/common/perf.dart';
import 'package:chessigma_mobile/src/model/common/speed.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history_provider.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history_storage.dart';
import 'package:chessigma_mobile/src/model/game/game_status.dart';
import 'package:chessigma_mobile/src/styles/chessigma_icons.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/view/external_history/external_game_history_screen.dart';
import 'package:chessigma_mobile/src/view/more/import_pgn_screen.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/neon_button.dart';
import 'package:chessigma_mobile/src/widgets/cyberpunk/glass_card.dart';
import 'package:dartchess/dartchess.dart' hide Variant;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class ExternalGameFetchWidget extends ConsumerStatefulWidget {
  const ExternalGameFetchWidget({super.key});

  @override
  ConsumerState<ExternalGameFetchWidget> createState() => _ExternalGameFetchWidgetState();
}

class _ExternalGameFetchWidgetState extends ConsumerState<ExternalGameFetchWidget> {
  ExternalSource _selectedSource = ExternalSource.chesscom;
  final _usernameController = TextEditingController();
  final _pgnController = TextEditingController();
  bool _isPgnSelected = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pgnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputBgColor = Colors.white.withValues(alpha: 0.05);

    return Padding(
      padding: Styles.bodySectionPadding,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Source Selection
            Row(
              children: [
                Expanded(
                  child: _SourceCard(
                    title: 'Chess.com',
                    icon: Icons.person, 
                    isSelected: !_isPgnSelected && _selectedSource == ExternalSource.chesscom,
                    onTap: () => setState(() {
                      _isPgnSelected = false;
                      _selectedSource = ExternalSource.chesscom;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SourceCard(
                    title: 'Lichess.org',
                    icon: ChessigmaIcons.logo_lichess,
                    isSelected: !_isPgnSelected && _selectedSource == ExternalSource.lichess,
                    onTap: () => setState(() {
                      _isPgnSelected = false;
                      _selectedSource = ExternalSource.lichess;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SourceCard(
                    title: 'PGN',
                    icon: Icons.description,
                    isSelected: _isPgnSelected,
                    onTap: () => setState(() {
                      _isPgnSelected = true;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isPgnSelected) ...[
              Text(
                '${_selectedSource.displayName} username',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: _selectedSource == ExternalSource.chesscom ? 'MagnusCarlsen' : 'DrNykterstein',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  onPressed: _handleFetch,
                  label: 'Fetch Recent Games',
                  glowColor: const Color(0xFFE8B84B), // Gold glow for external search
                ),
              ),
            ] else ...[
              Text(
                'Username',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Akenosir',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PGN Content',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                  TextButton.icon(
                    onPressed: _pickPgnFile,
                    icon: const Icon(Icons.upload, size: 16, color: Colors.white),
                    label: const Text('Import File', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pgnController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Paste PGN games here or import a file... (supports multiple games)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: inputBgColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  onPressed: _handleImportPgn,
                  label: 'Import PGN Games',
                  glowColor: const Color(0xFFE8B84B),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent History',
                  style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFFE8B84B), fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    ref.invalidate(externalGameHistorySourceLocalProvider(
                      _isPgnSelected ? ExternalSource.pgn : _selectedSource,
                    ));
                  },
                  child: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _GameHistoryList(source: _isPgnSelected ? ExternalSource.pgn : _selectedSource),

            const SizedBox(height: 24),
            if (!_isPgnSelected)
              const Text(
                'Try it out:',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              )
            else
              const Text(
                'You can paste one or multiple PGN games to import them',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TryItOutAvatar(
                    name: 'Magnus Carlsen',
                    imageUrl: 'assets/images/anon-face.webp',
                    onTap: () => _usernameController.text = 'MagnusCarlsen',
                  ),
                  const SizedBox(width: 8),
                  _TryItOutAvatar(
                    name: 'GothamChess',
                    imageUrl: 'assets/images/anon-face.webp',
                    onTap: () => _usernameController.text = 'GothamChess',
                  ),
                  const SizedBox(width: 8),
                  _TryItOutAvatar(
                    name: 'Hikaru vs Magnus',
                    imageUrl: 'assets/images/anon-face.webp',
                    onTap: () {
                      _usernameController.text = 'Hikaru';
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFetch() {
    final username = _usernameController.text.trim().isEmpty ? 'Anonymous' : _usernameController.text.trim();

    Navigator.of(context).push(
      ExternalGameHistoryScreen.buildRoute(
        context,
        ExternalUserHistoryParams(source: _selectedSource, username: username),
      ),
    );
  }

  Future<void> _handleImportPgn() async {
    final pgn = _pgnController.text.trim();
    final username = _usernameController.text.trim();
    if (pgn.isEmpty) return;

    // Save to history
    try {
      final pgnGames = PgnGame.parseMultiGamePgn(pgn);
      if (pgnGames.isNotEmpty) {
        final storage = ref.read(externalHistoryStorageProvider);
        final baseId = DateTime.now().millisecondsSinceEpoch;
        for (var i = 0; i < pgnGames.length && i < 3; i++) {
          final game = pgnGames[i];
          final headers = game.headers;
          final item = ExternalGameHistoryItem(
            source: ExternalSource.pgn,
            username: username.isEmpty ? 'Anonymous' : username,
            externalGameId: '${baseId}_$i',
            pgn: game.makePgn(),
            players: ExternalGamePlayers(
              white: ExternalPlayer(name: headers['White'] ?? 'White'),
              black: ExternalPlayer(name: headers['Black'] ?? 'Black'),
            ),
            createdAt: DateTime.now(),
            status: GameStatus.mate,
            variant: Variant.standard,
            speed: Speed.classical,
            perf: Perf.classical,
            rated: false,
          );
          await storage.save(item);
        }
        final finalUsername = username.isEmpty ? 'Anonymous' : username;
        ref.invalidate(externalGameHistoryLocalProvider(
          ExternalUserHistoryParams(source: ExternalSource.pgn, username: finalUsername),
        ));
      }
    } catch (e) {
      debugPrint('Error saving PGN history: $e');
    }

    if (mounted) {
      ImportPgnScreen.handlePgnText(context, pgn);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: $e')),
        );
      }
    }
  }
}
class _GameHistoryList extends ConsumerWidget {
  const _GameHistoryList({required this.source});

  final ExternalSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(externalGameHistorySourceLocalProvider(source));

    return history.when(
      data: (games) {
        if (games.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Center(
              child: Text(
                'No recent games',
                style: TextStyle(color: Colors.white24, fontSize: 13),
              ),
            ),
          );
        }

        final displayGames = games.take(15).toList();
        return Column(
          children: displayGames.map((game) => _GameHistoryItem(game: game)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading history: $e'),
    );
  }
}

class _GameHistoryItem extends StatelessWidget {
  const _GameHistoryItem({required this.game});

  final ExternalGameHistoryItem game;

  @override
  Widget build(BuildContext context) {
    final pov = game.orientationForUsername(game.username) ?? Side.white;
    final isWinner = game.winner == pov;
    final isDraw = game.winner == null;

    final resultColor = isWinner
        ? Colors.greenAccent
        : isDraw
            ? Colors.white54
            : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: () {
          ImportPgnScreen.handlePgnText(context, game.pgn);
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.chess_pawn_rounded,
                color: resultColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.players.white.name} vs ${game.players.black.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${game.username} • ${_formatDate(game.createdAt)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFE8B84B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: accentColor, width: 2.5) : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 32, color: isSelected ? accentColor : Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TryItOutAvatar extends StatelessWidget {
  const _TryItOutAvatar({
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
