import 'dart:convert';

import 'package:exochess_mobile/src/model/common/chess.dart';
import 'package:exochess_mobile/src/model/common/perf.dart';
import 'package:exochess_mobile/src/model/common/speed.dart';
import 'package:exochess_mobile/src/model/external_history/external_history.dart';
import 'package:exochess_mobile/src/model/external_history/external_history_provider.dart';
import 'package:exochess_mobile/src/model/external_history/external_history_storage.dart';
import 'package:exochess_mobile/src/model/game/game_status.dart';
import 'package:exochess_mobile/src/styles/exochess_icons.dart';
import 'package:exochess_mobile/src/styles/styles.dart';
import 'package:exochess_mobile/src/view/external_history/external_game_history_screen.dart';
import 'package:exochess_mobile/src/view/more/import_pgn_screen.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/neon_button.dart';
import 'package:exochess_mobile/src/widgets/cyberpunk/glass_card.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Padding(
      padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(top: 4, bottom: 8)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EXTERNAL GAMES',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: 'SpaceMono',
                  letterSpacing: 2.0,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              const SizedBox(height: 24),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceCard(
                      title: 'Lichess.org',
                      icon: ExoChessIcons.logo_lichess,
                      isSelected: !_isPgnSelected && _selectedSource == ExternalSource.lichess,
                      onTap: () => setState(() {
                        _isPgnSelected = false;
                        _selectedSource = ExternalSource.lichess;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 32),

              if (!_isPgnSelected) ...[
                Text(
                  '${_selectedSource.displayName} username'.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: _selectedSource == ExternalSource.chesscom
                        ? 'MagnusCarlsen'
                        : 'DrNykterstein',
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'SpaceMono'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _handleFetch,
                  child: const Text('FETCH RECENT GAMES'),
                ),
              ] else ...[
                Text(
                  'USERNAME',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpaceMono',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Akenosir',
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'SpaceMono'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PGN CONTENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickPgnFile,
                      icon: const Icon(Icons.upload, size: 16),
                      label: const Text('IMPORT FILE'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pgnController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Paste PGN games here...',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'SpaceMono'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _handleImportPgn,
                  child: const Text('IMPORT PGN GAMES'),
                ),
              ],

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT HISTORY',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'NDot',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.invalidate(
                        externalGameHistorySourceLocalProvider(
                          _isPgnSelected ? ExternalSource.pgn : _selectedSource,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _GameHistoryList(source: _isPgnSelected ? ExternalSource.pgn : _selectedSource),

              const SizedBox(height: 32),
              Text(
                _isPgnSelected ? 'Import multiple games by pasting them above.' : 'Try with top players:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontFamily: 'SpaceMono',
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TryItOutAvatar(
                      name: 'Magnus Carlsen',
                      imageUrl: 'assets/images/anon-face.webp',
                      onTap: () => _usernameController.text = 'MagnusCarlsen',
                    ),
                    const SizedBox(width: 12),
                    _TryItOutAvatar(
                      name: 'GothamChess',
                      imageUrl: 'assets/images/anon-face.webp',
                      onTap: () => _usernameController.text = 'GothamChess',
                    ),
                    const SizedBox(width: 12),
                    _TryItOutAvatar(
                      name: 'Hikaru',
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
      ),
    );
  }

  void _handleFetch() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Please enter a username',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

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
        ref.invalidate(
          externalGameHistoryLocalProvider(
            ExternalUserHistoryParams(source: ExternalSource.pgn, username: finalUsername),
          ),
        );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading file: $e')));
      }
    }
  }
}

class _GameHistoryList extends ConsumerStatefulWidget {
  const _GameHistoryList({required this.source});

  final ExternalSource source;

  @override
  ConsumerState<_GameHistoryList> createState() => _GameHistoryListState();
}

class _GameHistoryListState extends ConsumerState<_GameHistoryList> {
  bool _isExpanded = false;
  static const int _initialCount = 3;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(externalGameHistorySourceLocalProvider(widget.source));
    final theme = Theme.of(context);

    return history.when(
      data: (games) {
        if (games.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: const Center(
              child: Text(
                'NO RECENT GAMES',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        }

        final totalGamesList = games.toList();
        final displayGames =
            _isExpanded ? totalGamesList : totalGamesList.take(_initialCount).toList();

        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: displayGames.map((game) => _GameHistoryItem(game: game)).toList(),
              ),
            ),
            if (totalGamesList.length > _initialCount)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (_isExpanded ? 'COLLAPSE' : 'SHOW MORE').toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pov = game.orientationForUsername(game.username) ?? Side.white;
    final isWinner = game.winner == pov;
    final isDraw = game.winner == null;

    final resultColor = isWinner
        ? Colors.green
        : isDraw
        ? Colors.grey
        : const Color(0xFFD71921);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ImportPgnScreen.handlePgnText(context, game.pgn);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: resultColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${game.players.white.name} vs ${game.players.black.name}'.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: 'SpaceMono',
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game.username} • ${_formatDate(game.createdAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: 'SpaceMono',
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
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
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? accentColor : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(height: 12),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'SpaceMono',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TryItOutAvatar extends StatelessWidget {
  const _TryItOutAvatar({required this.name, required this.imageUrl, required this.onTap});

  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(width: 12),
            Text(
              name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'SpaceMono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
