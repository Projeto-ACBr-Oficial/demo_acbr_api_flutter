import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/network/http_client.dart';
import '../core/exceptions/api_exception.dart';
import '../models/auth/token_model.dart';
import '../models/auth/token_scope.dart';

class AuthService {
  final HttpClient _httpClient;

  /// Cache em memória: um token por scope.
  final Map<TokenScope, TokenModel> _cache = {};

  AuthService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  /// Retorna um token válido para o [scope] informado.
  /// Busca na ordem: memória → SharedPreferences → nova requisição OAuth2.
  Future<String> getToken(TokenScope scope) async {
    final cached = _cache[scope];
    if (cached != null && !cached.isExpired) {
      debugPrint('[AuthService] Token "${scope.storageKey}" em memória válido. Reutilizando.');
      return cached.accessToken;
    }

    final stored = await _loadFromStorage(scope);
    if (stored != null && !stored.isExpired) {
      debugPrint('[AuthService] Token "${scope.storageKey}" carregado do storage. Reutilizando.');
      _cache[scope] = stored;
      return stored.accessToken;
    }

    debugPrint('[AuthService] Token "${scope.storageKey}" ausente ou expirado. Solicitando novo...');
    return _fetchToken(scope);
  }

  /// Remove o token de um scope específico da memória e do storage.
  Future<void> clearToken(TokenScope scope) async {
    debugPrint('[AuthService] Removendo token "${scope.storageKey}".');
    _cache.remove(scope);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(scope.storageKey);
  }

  /// Remove todos os tokens de todos os scopes.
  Future<void> clearAllTokens() async {
    debugPrint('[AuthService] Removendo todos os tokens.');
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    for (final scope in TokenScope.values) {
      await prefs.remove(scope.storageKey);
    }
  }

  Future<String> _fetchToken(TokenScope scope) async {
    debugPrint('[AuthService] POST ${ApiConstants.authBaseUrl}');
    debugPrint('[AuthService] client_id: ${ApiConstants.clientId} | scope: ${scope.scopeValue}');

    try {
      final response = await _httpClient.postFormData(
        ApiConstants.authBaseUrl,
        body: {
          'grant_type': 'client_credentials',
          'client_id': ApiConstants.clientId,
          'client_secret': ApiConstants.clientSecret,
          'scope': scope.scopeValue,
        },
      );

      final token = TokenModel.fromJson(response);
      _cache[scope] = token;
      await _saveToStorage(scope, token);

      debugPrint('[AuthService] Token "${scope.storageKey}" obtido. Expira em ${token.expiresIn}s.');
      return token.accessToken;
    } on ApiException catch (e) {
      debugPrint('[AuthService] Falha ao obter token "${scope.storageKey}": ${e.message} (${e.statusCode})');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Erro inesperado ao obter token "${scope.storageKey}": $e');
      throw TokenException(message: 'Erro ao autenticar scope ${scope.scopeValue}: $e');
    }
  }

  Future<void> _saveToStorage(TokenScope scope, TokenModel token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(scope.storageKey, jsonEncode(token.toJson()));
    debugPrint('[AuthService] Token "${scope.storageKey}" salvo no storage.');
  }

  Future<TokenModel?> _loadFromStorage(TokenScope scope) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(scope.storageKey);
      if (stored == null) {
        debugPrint('[AuthService] Nenhum token "${scope.storageKey}" no storage.');
        return null;
      }
      debugPrint('[AuthService] Token "${scope.storageKey}" encontrado no storage. Verificando validade...');
      return TokenModel.fromStoredJson(jsonDecode(stored) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AuthService] Erro ao ler token "${scope.storageKey}" do storage: $e');
      return null;
    }
  }
}
