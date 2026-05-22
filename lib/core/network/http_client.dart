import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../exceptions/api_exception.dart';

class HttpClient {
  final http.Client _client;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String url, {
    required String token,
    Map<String, String>? queryParams,
  }) async {
    final uri = queryParams != null
        ? Uri.parse(url).replace(queryParameters: queryParams)
        : Uri.parse(url);

    debugPrint('[HTTP] GET $uri');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await _client
          .get(uri, headers: _buildHeaders(token))
          .timeout(const Duration(milliseconds: ApiConstants.receiveTimeoutMs));
      stopwatch.stop();

      debugPrint('[HTTP] GET $uri → ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('[HTTP] Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[HTTP] SocketException em GET $uri: $e');
      throw const NetworkException();
    } on HttpException catch (e) {
      debugPrint('[HTTP] HttpException em GET $uri: $e');
      throw const NetworkException(message: 'Erro de conexão HTTP.');
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    debugPrint('[HTTP] POST $url');
    debugPrint('[HTTP] Body: ${jsonEncode(body)}');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: ApiConstants.receiveTimeoutMs));
      stopwatch.stop();

      debugPrint('[HTTP] POST $url → ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('[HTTP] Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[HTTP] SocketException em POST $url: $e');
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> postFormData(
    String url, {
    required Map<String, String> body,
  }) async {
    // Oculta client_secret no log
    final logBody = Map<String, String>.from(body)
      ..update('client_secret', (_) => '***', ifAbsent: () => '***');
    debugPrint('[HTTP] POST (form) $url');
    debugPrint('[HTTP] Form body: $logBody');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          )
          .timeout(const Duration(milliseconds: ApiConstants.connectTimeoutMs));
      stopwatch.stop();

      debugPrint('[HTTP] POST (form) $url → ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
      debugPrint('[HTTP] Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('[HTTP] SocketException em POST (form) $url: $e');
      throw const NetworkException();
    }
  }

  Map<String, String> _buildHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = _parseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ??
        body['error_description'] as String? ??
        body['error'] as String? ??
        'Erro desconhecido.';

    debugPrint('[HTTP] Erro ${response.statusCode}: $message');
    throw ApiException(statusCode: response.statusCode, message: message, data: body);
  }

  Map<String, dynamic> _parseBody(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'raw': body};
    }
  }

  void dispose() => _client.close();
}
