import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessigma_mobile/src/model/external_history/external_history.dart';
import 'package:chessigma_mobile/src/styles/chessigma_icons.dart';
import 'package:chessigma_mobile/src/styles/styles.dart';
import 'package:chessigma_mobile/src/view/external_history/external_game_history_screen.dart';
import 'package:chessigma_mobile/src/view/more/import_pgn_screen.dart';

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
  void dispose() {
    _usernameController.dispose();
    _pgnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFFE8B84B);
    final cardBgColor = theme.colorScheme.surfaceContainerHigh;
    final inputBgColor = theme.colorScheme.surfaceContainer;

    return Padding(
      padding: Styles.bodySectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: _selectedSource == ExternalSource.chesscom ? 'MagnusCarlsen' : 'DrNykterstein',
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleFetch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Fetch Recent Games',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ] else ...[
            Text(
              'Username',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Akenosir',
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PGN Content',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickPgnFile,
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Import PGN File'),
                  style: TextButton.styleFrom(
                    backgroundColor: cardBgColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                filled: true,
                fillColor: inputBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleImportPgn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Import PGN Games',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          if (!_isPgnSelected)
            const Text(
              'Try it out:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          else
            const Text(
              'You can paste one or multiple PGN games to import them',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          const SizedBox(height: 8),
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
    );
  }

  void _handleFetch() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    Navigator.of(context).push(
      ExternalGameHistoryScreen.buildRoute(
        context,
        ExternalUserHistoryParams(source: _selectedSource, username: username),
      ),
    );
  }

  void _handleImportPgn() {
    final pgn = _pgnController.text.trim();
    if (pgn.isEmpty) return;

    ImportPgnScreen.handlePgnText(context, pgn);
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
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: accentColor, width: 2) : Border.all(color: Colors.grey.withAlpha(50)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 32, color: isSelected ? accentColor : Colors.white70),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? accentColor : Colors.white70,
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
                  decoration: BoxDecoration(
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
