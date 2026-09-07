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

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async => _expect(await _send('GET', path, query: query));

  /// For endpoints that answer with a JSON array rather than an object.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async => _expect(await _send('GET', path, query: query));

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body: body).then(_expect);

  Future<Map<String, dynamic>> post(String path) =>
      _send('POST', path).then(_expect);

  T _expect<T>(({Object? body, int status}) response) {
    if (response.body is! T) throw ApiException(response.status, response.body);
    return response.body as T;
  }

  Future<({Object? body, int status})> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final token = await _accessToken();
    final uri = _baseUri.resolve(path);
    final request =
        http.Request(
            method,
            query == null ? uri : uri.replace(queryParameters: query),
          )
          ..headers.addAll({
            'accept': 'application/json',
            'authorization': 'Bearer $token',
            'content-type': 'application/json',
          });
    if (body != null) request.body = jsonEncode(body);

    final response = await http.Response.fromStream(await _http.send(request));
    final decoded = response.body.isEmpty
        ? null
        : jsonDecode(response.body) as Object?;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, decoded);
    }
    return (body: decoded, status: response.statusCode);
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final Object? body;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
