
void main() {
  const kLichessWSHost = 'socket.lichess.org';
  const unencodedPath = '/socket/v5';
  const sri = 'some-sri-123';
  
  final isLocal = kLichessWSHost.startsWith('localhost') ||
      kLichessWSHost.startsWith('127.0.0.1') ||
      kLichessWSHost.startsWith('10.') ||
      kLichessWSHost.startsWith('192.168.');

  final protocol = kLichessWSHost.contains('://') ? '' : (isLocal ? 'ws://' : 'wss://');
  var baseUri = Uri.parse('$protocol$kLichessWSHost');
  
  // Robustly create the final URI without fragment
  final queryParameters = {
    'sri': sri,
    'v': '1',
  };
  
  int? port = baseUri.hasPort ? baseUri.port : null;
  if (port == null || port == 0) {
    if (baseUri.scheme == 'wss' || baseUri.scheme == 'https') {
      port = 443;
    } else if (baseUri.scheme == 'ws' || baseUri.scheme == 'http') {
      port = 80;
    }
  }

  final finalUri = Uri(
    scheme: baseUri.scheme == 'https' ? 'wss' : (baseUri.scheme == 'http' ? 'ws' : baseUri.scheme),
    host: baseUri.host,
    port: port,
    path: unencodedPath,
    queryParameters: queryParameters,
  );
  
  print('Final URI: $finalUri');
  print('Has Fragment: ${finalUri.hasFragment}');
}
