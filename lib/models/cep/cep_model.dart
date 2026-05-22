class CepModel {
  final String cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? localidade;
  final String? uf;
  final String? ibge;
  final String? ddd;

  const CepModel({
    required this.cep,
    this.logradouro,
    this.complemento,
    this.bairro,
    this.localidade,
    this.uf,
    this.ibge,
    this.ddd,
  });

  factory CepModel.fromJson(Map<String, dynamic> json) {
    return CepModel(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      localidade: json['localidade'] as String? ?? json['cidade'] as String?,
      uf: json['uf'] as String? ?? json['estado'] as String?,
      ibge: json['ibge'] as String?,
      ddd: json['ddd'] as String?,
    );
  }

  String get enderecoCompleto {
    final parts = <String>[];
    if (logradouro != null && logradouro!.isNotEmpty) parts.add(logradouro!);
    if (bairro != null && bairro!.isNotEmpty) parts.add(bairro!);
    if (localidade != null) parts.add(localidade!);
    if (uf != null) parts.add(uf!);
    return parts.join(', ');
  }
}
