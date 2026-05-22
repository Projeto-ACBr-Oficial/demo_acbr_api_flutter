import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/cnpj_controller.dart';
import '../../models/cnpj/cnpj_model.dart';
import '../../widgets/info_row.dart';

class CnpjScreen extends StatefulWidget {
  const CnpjScreen({super.key});

  @override
  State<CnpjScreen> createState() => _CnpjScreenState();
}

class _CnpjScreenState extends State<CnpjScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();

  @override
  void dispose() {
    _cnpjController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CnpjController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchForm(context, controller),
              const SizedBox(height: 16),
              _buildResult(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchForm(BuildContext context, CnpjController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informe o CNPJ para consulta',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjController,
                decoration: InputDecoration(
                  labelText: 'CNPJ',
                  hintText: '00.000.000/0000-00',
                  prefixIcon: const Icon(Icons.business),
                  border: const OutlineInputBorder(),
                  suffixIcon: _cnpjController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _cnpjController.clear();
                            controller.reset();
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CnpjInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o CNPJ';
                  }
                  final digits = value.replaceAll(RegExp(r'[.\-/]'), '');
                  if (digits.length != 14) {
                    return 'CNPJ deve ter 14 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          controller.consultar(_cnpjController.text);
                        }
                      },
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                    controller.isLoading ? 'Consultando...' : 'Consultar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, CnpjController controller) {
    switch (controller.state) {
      case CnpjState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      case CnpjState.error:
        return _ErrorCard(message: controller.errorMessage ?? 'Erro desconhecido');
      case CnpjState.success:
        return _CnpjResultCard(cnpj: controller.cnpj!);
      case CnpjState.idle:
        return const _EmptyState();
    }
  }
}

class _CnpjResultCard extends StatelessWidget {
  final CnpjModel cnpj;

  const _CnpjResultCard({required this.cnpj});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _cardDadosPrincipais(),
        if (cnpj.situacaoCadastral != null) _cardSituacaoCadastral(),
        _cardPorteCapital(),
        if (cnpj.endereco != null) _cardEndereco(),
        if (cnpj.atividadePrincipal != null) _cardAtividades(),
        _cardContato(),
        if (cnpj.simples != null || cnpj.simei != null) _cardRegimeTributario(),
        if (cnpj.socios.isNotEmpty) _cardSocios(),
      ],
    );
  }

  Widget _cardDadosPrincipais() {
    final situacaoDescricao = cnpj.situacaoCadastral?.descricao;
    return InfoCard(
      title: 'Dados Principais',
      titleIcon: Icons.business,
      children: [
        Row(
          children: [
            Expanded(child: InfoRow(label: 'CNPJ', value: cnpj.cnpj)),
            if (situacaoDescricao != null)
              StatusChip(
                label: situacaoDescricao,
                isActive: situacaoDescricao.toUpperCase().contains('ATIVA'),
              ),
          ],
        ),
        InfoRow(label: 'Razão Social', value: cnpj.razaoSocial),
        InfoRow(label: 'Nome Fantasia', value: cnpj.nomeFantasia),
        InfoRow(label: 'Início Atividade', value: cnpj.dataInicioAtividade),
        InfoRow(
          label: 'Tipo',
          value: cnpj.matriz == null
              ? null
              : cnpj.matriz!
                  ? 'Matriz'
                  : 'Filial',
        ),
        InfoRow(label: 'Ente Federativo', value: cnpj.enteFederativoResponsavel),
      ],
    );
  }

  Widget _cardSituacaoCadastral() {
    final s = cnpj.situacaoCadastral!;
    final m = cnpj.motivoSituacaoCadastral;
    return InfoCard(
      title: 'Situação Cadastral',
      titleIcon: Icons.verified_outlined,
      children: [
        InfoRow(label: 'Código', value: s.codigo),
        InfoRow(label: 'Situação', value: s.descricao),
        InfoRow(label: 'Data', value: s.data),
        if (m != null) ...[
          InfoRow(label: 'Motivo', value: m.descricao),
          InfoRow(label: 'Data Motivo', value: m.data),
        ],
        if (cnpj.situacaoEspecial != null) ...[
          InfoRow(label: 'Sit. Especial', value: cnpj.situacaoEspecial!.descricao),
          InfoRow(label: 'Data Esp.', value: cnpj.situacaoEspecial!.data),
        ],
      ],
    );
  }

  Widget _cardPorteCapital() {
    return InfoCard(
      title: 'Porte & Capital',
      titleIcon: Icons.account_balance,
      children: [
        InfoRow(label: 'Porte', value: cnpj.porte?.descricao),
        InfoRow(
          label: 'Capital Social',
          value: cnpj.capitalSocial != null
              ? 'R\$ ${cnpj.capitalSocial!.toStringAsFixed(2)}'
              : null,
        ),
        InfoRow(label: 'Nat. Jurídica', value: cnpj.naturezaJuridica?.descricao),
        InfoRow(label: 'Cód. Nat. Jur.', value: cnpj.naturezaJuridica?.codigo),
        if (cnpj.pais != null)
          InfoRow(label: 'País', value: cnpj.pais!.descricao),
        if (cnpj.nomeCidadeExterior != null)
          InfoRow(label: 'Cidade Ext.', value: cnpj.nomeCidadeExterior),
      ],
    );
  }

  Widget _cardEndereco() {
    final e = cnpj.endereco!;
    return InfoCard(
      title: 'Endereço',
      titleIcon: Icons.location_on,
      children: [
        InfoRow(label: 'Logradouro', value: '${e.tipoLogradouro ?? ''} ${e.logradouro ?? ''}'.trim()),
        InfoRow(label: 'Número', value: e.numero),
        InfoRow(label: 'Complemento', value: e.complemento),
        InfoRow(label: 'Bairro', value: e.bairro),
        InfoRow(label: 'Município', value: e.municipio?.descricao),
        InfoRow(label: 'Cód. IBGE', value: e.municipio?.codigoIbge),
        InfoRow(label: 'UF', value: e.uf),
        InfoRow(label: 'CEP', value: e.cep),
      ],
    );
  }

  Widget _cardAtividades() {
    return InfoCard(
      title: 'Atividades',
      titleIcon: Icons.work,
      children: [
        InfoRow(label: 'Principal', value: cnpj.atividadePrincipal!.descricao),
        InfoRow(label: 'Código', value: cnpj.atividadePrincipal!.codigo),
        if (cnpj.atividadesSecundarias.isNotEmpty) ...[
          const SizedBox(height: 4),
          const Text(
            'Secundárias',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
          ),
          ...cnpj.atividadesSecundarias.map(
            (a) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InfoRow(label: a.codigo ?? '', value: a.descricao),
            ),
          ),
        ],
      ],
    );
  }

  Widget _cardContato() {
    return InfoCard(
      title: 'Contato',
      titleIcon: Icons.contact_phone,
      children: [
        InfoRow(label: 'E-mail', value: cnpj.email, icon: Icons.email),
        ...cnpj.telefones.map(
          (t) => InfoRow(label: 'Telefone', value: t.formatado, icon: Icons.phone),
        ),
      ],
    );
  }

  Widget _cardRegimeTributario() {
    return InfoCard(
      title: 'Regime Tributário',
      titleIcon: Icons.receipt_long,
      children: [
        if (cnpj.simples != null) ...[
          InfoRow(
            label: 'Simples Nacional',
            value: cnpj.simples!.optante == true ? 'Optante' : 'Não optante',
          ),
          InfoRow(label: 'Data Opção', value: cnpj.simples!.dataOpcao),
          InfoRow(label: 'Data Exclusão', value: cnpj.simples!.dataExclusao),
        ],
        if (cnpj.simei != null) ...[
          InfoRow(
            label: 'SIMEI',
            value: cnpj.simei!.optante == true ? 'Optante' : 'Não optante',
          ),
          InfoRow(label: 'Data Opção', value: cnpj.simei!.dataOpcao),
          InfoRow(label: 'Data Exclusão', value: cnpj.simei!.dataExclusao),
        ],
      ],
    );
  }

  Widget _cardSocios() {
    return InfoCard(
      title: 'Quadro Societário',
      titleIcon: Icons.people,
      children: [
        ...cnpj.socios.map((s) => _SocioTile(socio: s)),
      ],
    );
  }
}

class _SocioTile extends StatelessWidget {
  final CnpjSocio socio;

  const _SocioTile({required this.socio});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Nome', value: socio.nome),
          InfoRow(label: 'CPF/CNPJ', value: socio.cpfCnpj),
          InfoRow(label: 'Qualificação', value: socio.qualificacao?.descricao),
          InfoRow(label: 'Entrada', value: socio.dataEntradaSociedade),
          InfoRow(label: 'Faixa Etária', value: socio.faixaEtaria?.descricao),
          if (socio.representanteLegal?.nome != null) ...[
            InfoRow(label: 'Representante', value: socio.representanteLegal!.nome),
            InfoRow(label: 'CPF Rep.', value: socio.representanteLegal!.cpf),
          ],
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.business_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Informe um CNPJ para consultar',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 14; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
