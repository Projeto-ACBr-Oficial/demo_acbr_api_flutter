import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/http_client.dart';
import '../models/auth/token_scope.dart';
import '../models/cnpj/cnpj_model.dart';
import 'auth_service.dart';

class CnpjService {
  final HttpClient _httpClient;
  final AuthService _authService;

  CnpjService({HttpClient? httpClient, AuthService? authService})
      : _httpClient = httpClient ?? HttpClient(),
        _authService = authService ?? AuthService();

  Future<CnpjModel> consultar(String cnpj) async {
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[.\-/]'), '');
    debugPrint('[CnpjService] Consultando CNPJ: $cnpjLimpo');

    final token = await _authService.getToken(TokenScope.cnpj);

    final url = '${ApiConstants.apiBaseUrl}/cnpj/$cnpjLimpo';
    debugPrint('[CnpjService] URL: $url');

    final response = await _httpClient.get(url, token: token);
    final model = CnpjModel.fromJson(response);

    debugPrint('[CnpjService] Resultado: ${model.razaoSocial} | Situação: ${model.situacaoCadastral?.descricao}');
    return model;
  }
}
