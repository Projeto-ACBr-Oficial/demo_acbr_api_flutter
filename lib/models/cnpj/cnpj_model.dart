// Padrão reutilizável para objetos { codigo, descricao }
class CnpjCodigoDescricao {
  final String? codigo;
  final String? descricao;

  const CnpjCodigoDescricao({this.codigo, this.descricao});

  factory CnpjCodigoDescricao.fromJson(Map<String, dynamic> json) =>
      CnpjCodigoDescricao(
        codigo: json['codigo'] as String?,
        descricao: json['descricao'] as String?,
      );
}

// Padrão reutilizável para objetos { data, codigo, descricao }
class CnpjSituacao {
  final String? data;
  final String? codigo;
  final String? descricao;

  const CnpjSituacao({this.data, this.codigo, this.descricao});

  factory CnpjSituacao.fromJson(Map<String, dynamic> json) => CnpjSituacao(
        data: json['data'] as String?,
        codigo: json['codigo'] as String?,
        descricao: json['descricao'] as String?,
      );
}

class CnpjMunicipio {
  final String? codigoTom;
  final String? codigoIbge;
  final String? descricao;

  const CnpjMunicipio({this.codigoTom, this.codigoIbge, this.descricao});

  factory CnpjMunicipio.fromJson(Map<String, dynamic> json) => CnpjMunicipio(
        codigoTom: json['codigo_tom'] as String?,
        codigoIbge: json['codigo_ibge'] as String?,
        descricao: json['descricao'] as String?,
      );
}

class CnpjEndereco {
  final String? tipoLogradouro;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cep;
  final String? uf;
  final CnpjMunicipio? municipio;

  const CnpjEndereco({
    this.tipoLogradouro,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cep,
    this.uf,
    this.municipio,
  });

  factory CnpjEndereco.fromJson(Map<String, dynamic> json) => CnpjEndereco(
        tipoLogradouro: json['tipo_logradouro'] as String?,
        logradouro: json['logradouro'] as String?,
        numero: json['numero'] as String?,
        complemento: json['complemento'] as String?,
        bairro: json['bairro'] as String?,
        cep: json['cep'] as String?,
        uf: json['uf'] as String?,
        municipio: json['municipio'] != null
            ? CnpjMunicipio.fromJson(json['municipio'] as Map<String, dynamic>)
            : null,
      );

  String get enderecoCompleto {
    final parts = <String>[];
    if (tipoLogradouro != null) parts.add(tipoLogradouro!);
    if (logradouro != null) parts.add(logradouro!);
    if (numero != null) parts.add(numero!);
    if (complemento != null && complemento!.isNotEmpty) parts.add(complemento!);
    if (bairro != null) parts.add(bairro!);
    if (municipio?.descricao != null) parts.add(municipio!.descricao!);
    if (uf != null) parts.add(uf!);
    if (cep != null) parts.add('CEP: ${cep!}');
    return parts.join(', ');
  }
}

class CnpjTelefone {
  final String? ddd;
  final String? numero;

  const CnpjTelefone({this.ddd, this.numero});

  factory CnpjTelefone.fromJson(Map<String, dynamic> json) => CnpjTelefone(
        ddd: json['ddd'] as String?,
        numero: json['numero'] as String?,
      );

  String get formatado => ddd != null ? '($ddd) $numero' : numero ?? '';
}

class CnpjOptante {
  final bool? optante;
  final String? dataOpcao;
  final String? dataExclusao;

  const CnpjOptante({this.optante, this.dataOpcao, this.dataExclusao});

  factory CnpjOptante.fromJson(Map<String, dynamic> json) => CnpjOptante(
        optante: json['optante'] as bool?,
        dataOpcao: json['data_opcao'] as String?,
        dataExclusao: json['data_exclusao'] as String?,
      );
}

class CnpjRepresentanteLegal {
  final String? cpf;
  final String? nome;
  final CnpjCodigoDescricao? qualificacao;

  const CnpjRepresentanteLegal({this.cpf, this.nome, this.qualificacao});

  factory CnpjRepresentanteLegal.fromJson(Map<String, dynamic> json) =>
      CnpjRepresentanteLegal(
        cpf: json['cpf'] as String?,
        nome: json['nome'] as String?,
        qualificacao: json['qualificacao'] != null
            ? CnpjCodigoDescricao.fromJson(
                json['qualificacao'] as Map<String, dynamic>)
            : null,
      );
}

class CnpjSocio {
  final CnpjCodigoDescricao? identificadorSocio;
  final String? nome;
  final String? cpfCnpj;
  final CnpjCodigoDescricao? qualificacao;
  final String? dataEntradaSociedade;
  final CnpjCodigoDescricao? pais;
  final CnpjRepresentanteLegal? representanteLegal;
  final CnpjCodigoDescricao? faixaEtaria;

  const CnpjSocio({
    this.identificadorSocio,
    this.nome,
    this.cpfCnpj,
    this.qualificacao,
    this.dataEntradaSociedade,
    this.pais,
    this.representanteLegal,
    this.faixaEtaria,
  });

  factory CnpjSocio.fromJson(Map<String, dynamic> json) => CnpjSocio(
        identificadorSocio: json['identificador_socio'] != null
            ? CnpjCodigoDescricao.fromJson(
                json['identificador_socio'] as Map<String, dynamic>)
            : null,
        nome: json['nome'] as String?,
        cpfCnpj: json['cpf_cnpj'] as String?,
        qualificacao: json['qualificacao'] != null
            ? CnpjCodigoDescricao.fromJson(
                json['qualificacao'] as Map<String, dynamic>)
            : null,
        dataEntradaSociedade: json['data_entrada_sociedade'] as String?,
        pais: json['pais'] != null
            ? CnpjCodigoDescricao.fromJson(json['pais'] as Map<String, dynamic>)
            : null,
        representanteLegal: json['representante_legal'] != null
            ? CnpjRepresentanteLegal.fromJson(
                json['representante_legal'] as Map<String, dynamic>)
            : null,
        faixaEtaria: json['faixa_etaria'] != null
            ? CnpjCodigoDescricao.fromJson(
                json['faixa_etaria'] as Map<String, dynamic>)
            : null,
      );
}

class CnpjModel {
  final String cnpj;
  final String? razaoSocial;
  final String? nomeFantasia;
  final String? dataInicioAtividade;
  final bool? matriz;
  final CnpjCodigoDescricao? naturezaJuridica;
  final double? capitalSocial;
  final CnpjCodigoDescricao? porte;
  final String? enteFederativoResponsavel;
  final CnpjSituacao? situacaoCadastral;
  final CnpjSituacao? motivoSituacaoCadastral;
  final String? nomeCidadeExterior;
  final CnpjCodigoDescricao? pais;
  final CnpjCodigoDescricao? atividadePrincipal;
  final List<CnpjCodigoDescricao> atividadesSecundarias;
  final CnpjEndereco? endereco;
  final List<CnpjTelefone> telefones;
  final String? email;
  final CnpjSituacao? situacaoEspecial;
  final CnpjOptante? simples;
  final CnpjOptante? simei;
  final List<CnpjSocio> socios;

  const CnpjModel({
    required this.cnpj,
    this.razaoSocial,
    this.nomeFantasia,
    this.dataInicioAtividade,
    this.matriz,
    this.naturezaJuridica,
    this.capitalSocial,
    this.porte,
    this.enteFederativoResponsavel,
    this.situacaoCadastral,
    this.motivoSituacaoCadastral,
    this.nomeCidadeExterior,
    this.pais,
    this.atividadePrincipal,
    this.atividadesSecundarias = const [],
    this.endereco,
    this.telefones = const [],
    this.email,
    this.situacaoEspecial,
    this.simples,
    this.simei,
    this.socios = const [],
  });

  factory CnpjModel.fromJson(Map<String, dynamic> json) {
    return CnpjModel(
      cnpj: json['cnpj'] as String? ?? '',
      razaoSocial: json['razao_social'] as String?,
      nomeFantasia: json['nome_fantasia'] as String?,
      dataInicioAtividade: json['data_inicio_atividade'] as String?,
      matriz: json['matriz'] as bool?,
      naturezaJuridica: json['natureza_juridica'] != null
          ? CnpjCodigoDescricao.fromJson(
              json['natureza_juridica'] as Map<String, dynamic>)
          : null,
      capitalSocial: (json['capital_social'] as num?)?.toDouble(),
      porte: json['porte'] != null
          ? CnpjCodigoDescricao.fromJson(json['porte'] as Map<String, dynamic>)
          : null,
      enteFederativoResponsavel:
          json['ente_federativo_responsavel'] as String?,
      situacaoCadastral: json['situacao_cadastral'] != null
          ? CnpjSituacao.fromJson(
              json['situacao_cadastral'] as Map<String, dynamic>)
          : null,
      motivoSituacaoCadastral: json['motivo_situacao_cadastral'] != null
          ? CnpjSituacao.fromJson(
              json['motivo_situacao_cadastral'] as Map<String, dynamic>)
          : null,
      nomeCidadeExterior: json['nome_da_cidade_no_exterior'] as String?,
      pais: json['pais'] != null
          ? CnpjCodigoDescricao.fromJson(json['pais'] as Map<String, dynamic>)
          : null,
      atividadePrincipal: json['atividade_principal'] != null
          ? CnpjCodigoDescricao.fromJson(
              json['atividade_principal'] as Map<String, dynamic>)
          : null,
      atividadesSecundarias:
          (json['atividades_secundarias'] as List<dynamic>? ?? [])
              .map((e) =>
                  CnpjCodigoDescricao.fromJson(e as Map<String, dynamic>))
              .toList(),
      endereco: json['endereco'] != null
          ? CnpjEndereco.fromJson(json['endereco'] as Map<String, dynamic>)
          : null,
      telefones: (json['telefones'] as List<dynamic>? ?? [])
          .map((e) => CnpjTelefone.fromJson(e as Map<String, dynamic>))
          .toList(),
      email: json['email'] as String?,
      situacaoEspecial: json['situacao_especial'] != null
          ? CnpjSituacao.fromJson(
              json['situacao_especial'] as Map<String, dynamic>)
          : null,
      simples: json['simples'] != null
          ? CnpjOptante.fromJson(json['simples'] as Map<String, dynamic>)
          : null,
      simei: json['simei'] != null
          ? CnpjOptante.fromJson(json['simei'] as Map<String, dynamic>)
          : null,
      socios: (json['socios'] as List<dynamic>? ?? [])
          .map((e) => CnpjSocio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
