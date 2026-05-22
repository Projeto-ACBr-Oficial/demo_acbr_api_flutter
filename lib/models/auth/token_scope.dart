enum TokenScope {
  cnpj('cnpj_token', 'cnpj'),
  cep('cep_token', 'cep'),
  nfe('nfe_token', 'nfe'),
  nfce('nfce_token', 'nfce'),
  nfse('nfse_token', 'nfse');

  /// Chave usada no SharedPreferences para este scope.
  final String storageKey;

  /// Valor enviado no campo `scope` da requisição OAuth2.
  final String scopeValue;

  const TokenScope(this.storageKey, this.scopeValue);
}
