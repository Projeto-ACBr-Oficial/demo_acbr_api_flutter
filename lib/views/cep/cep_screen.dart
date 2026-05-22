import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/cep_controller.dart';
import '../../models/cep/cep_model.dart';
import '../../widgets/info_row.dart';

class CepScreen extends StatefulWidget {
  const CepScreen({super.key});

  @override
  State<CepScreen> createState() => _CepScreenState();
}

class _CepScreenState extends State<CepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CepController>(
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

  Widget _buildSearchForm(BuildContext context, CepController controller) {
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
                'Informe o CEP para consulta',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  hintText: '00000-000',
                  prefixIcon: const Icon(Icons.location_on),
                  border: const OutlineInputBorder(),
                  suffixIcon: _cepController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _cepController.clear();
                            controller.reset();
                          },
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CepInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o CEP';
                  }
                  final digits = value.replaceAll('-', '');
                  if (digits.length != 8) {
                    return 'CEP deve ter 8 dígitos';
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
                          controller.consultar(_cepController.text);
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
                label:
                    Text(controller.isLoading ? 'Consultando...' : 'Consultar'),
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

  Widget _buildResult(BuildContext context, CepController controller) {
    switch (controller.state) {
      case CepState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      case CepState.error:
        return _ErrorCard(
            message: controller.errorMessage ?? 'Erro desconhecido');
      case CepState.success:
        return _CepResultCard(cep: controller.cep!);
      case CepState.idle:
        return const _EmptyState();
    }
  }
}

class _CepResultCard extends StatelessWidget {
  final CepModel cep;

  const _CepResultCard({required this.cep});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Endereço Encontrado',
      titleIcon: Icons.location_on,
      children: [
        InfoRow(label: 'CEP', value: cep.cep, icon: Icons.pin_drop),
        InfoRow(
            label: 'Logradouro',
            value: cep.logradouro,
            icon: Icons.signpost),
        InfoRow(
            label: 'Complemento',
            value: cep.complemento,
            icon: Icons.add_location),
        InfoRow(label: 'Bairro', value: cep.bairro, icon: Icons.map),
        InfoRow(
            label: 'Cidade',
            value: cep.localidade,
            icon: Icons.location_city),
        InfoRow(label: 'Estado', value: cep.uf, icon: Icons.flag),
        InfoRow(label: 'DDD', value: cep.ddd, icon: Icons.phone),
        InfoRow(
            label: 'Código IBGE', value: cep.ibge, icon: Icons.numbers),
      ],
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
            Icon(Icons.location_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Informe um CEP para consultar',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
