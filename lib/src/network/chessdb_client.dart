import 'package:http/http.dart' as http;

class ChessDBClient {
  static const String _baseUrl = 'http://www.chessdb.cn/cdb.php';

  Future<String> queryAll(String fen) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'action': 'queryall',
      'board': fen,
    });
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to query ChessDB: ${response.statusCode}');
    }
  }
}
