import 'dart:convert';

import 'package:http/http.dart' as http;

typedef AccessTokenProvider = Future<String> Function();

class ApiClient {
  ApiClient({
    required Uri baseUri,
    required AccessTokenProvider accessToken,
    http.Client? httpClient,
  }) : _baseUri = baseUri,
       _accessToken = accessToken,
       _http = httpClient ?? http.Client();

  final Uri _baseUri;
  final AccessTokenProvider _accessToken;
  final http.Client _http;

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body: body);

  Future<Map<String, dynamic>> post(String path) => _send('POST', path);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _accessToken();
    final request = http.Request(method, _baseUri.resolve(path))
      ..headers.addAll({
        'accept': 'application/json',
        'authorization': 'Bearer $token',
        'content-type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);

    final response = await http.Response.fromStream(await _http.send(request));
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, decoded);
    }
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(response.statusCode, decoded);
    }
    return decoded;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final Object? body;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
