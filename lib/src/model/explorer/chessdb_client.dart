import 'package:http/http.dart' as http;

class ChessDBClient {
  static const String _baseUrl = 'http://www.chessdb.cn/cdb.php';

  Future<String> queryAll(String fen) async {
    try {
      final encodedFen = Uri.encodeComponent(fen);
      // Try HTTPS first, if it fails fallback to HTTP
      try {
        final response = await http.get(Uri.parse('https://www.chessdb.cn/cdb.php?action=queryall&board=$encodedFen'));
        if (response.statusCode == 200) return response.body;
      } catch (_) {}

      final response = await http.get(Uri.parse('$_baseUrl?action=queryall&board=$encodedFen'));
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      // Log error if needed
    }
    return 'unknown';
  }
}
