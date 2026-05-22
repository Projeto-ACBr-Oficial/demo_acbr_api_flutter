import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/http_client.dart';
import '../models/auth/token_scope.dart';
import '../models/cep/cep_model.dart';
import 'auth_service.dart';

class CepService {
  final HttpClient _httpClient;
  final AuthService _authService;

  CepService({HttpClient? httpClient, AuthService? authService})
      : _httpClient = httpClient ?? HttpClient(),
        _authService = authService ?? AuthService();

  Future<CepModel> consultar(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[.\-]'), '');
    debugPrint('[CepService] Consultando CEP: $cepLimpo');

    final token = await _authService.getToken(TokenScope.cep);

    final url = '${ApiConstants.apiBaseUrl}/cep/$cepLimpo';
    debugPrint('[CepService] URL: $url');

    final response = await _httpClient.get(url, token: token);
    final model = CepModel.fromJson(response);

    debugPrint('[CepService] Resultado: ${model.enderecoCompleto}');
    return model;
  }
}
