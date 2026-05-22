/// ⚠️  ATENÇÃO — PROJETO DE EXEMPLO
///
/// Este projeto é apenas uma demonstração de integração com a ACBr API.
/// As credenciais (CLIENT_ID e CLIENT_SECRET) NUNCA devem ser armazenadas
/// diretamente no código-fonte ou commitadas no repositório.
///
/// Em produção, forneça as credenciais via --dart-define ou
/// --dart-define-from-file (veja o README.md para instruções completas).
class ApiConstants {
  static const String authBaseUrl =
      'https://auth.acbr.api.br/realms/ACBrAPI/protocol/openid-connect/token';

  // Sandbox: 'https://hom.acbr.api.br' | Produção: 'https://prod.acbr.api.br'
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hom.acbr.api.br',
  );

  static const String clientId = String.fromEnvironment(
    'CLIENT_ID',
    defaultValue: '',
  );

  static const String clientSecret = String.fromEnvironment(
    'CLIENT_SECRET',
    defaultValue: '',
  );

  static const String scopeCnpj = 'cnpj';
  static const String scopeCep = 'cep';
  static const String scopeNfe = 'nfe';
  static const String scopeAll = 'cnpj cep nfe nfce nfse';

  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
