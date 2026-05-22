class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Requisição inválida. Verifique os dados informados.';
      case 401:
        return 'Não autorizado. Credenciais inválidas ou token expirado.';
      case 403:
        return 'Acesso negado. Verifique as permissões da sua conta.';
      case 404:
        return 'Recurso não encontrado.';
      case 422:
        return 'Dados inválidos: $message';
      case 429:
        return 'Muitas requisições. Aguarde um momento e tente novamente.';
      case 500:
        return 'Erro interno do servidor. Tente novamente mais tarde.';
      default:
        return message;
    }
  }
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Sem conexão com a internet.'});
}

class TokenException extends ApiException {
  const TokenException({super.message = 'Falha ao obter token de acesso.'})
      : super(statusCode: 401);
}
