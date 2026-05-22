import 'package:flutter/foundation.dart';
import '../core/exceptions/api_exception.dart';
import '../models/cnpj/cnpj_model.dart';
import '../services/cnpj_service.dart';

enum CnpjState { idle, loading, success, error }

class CnpjController extends ChangeNotifier {
  final CnpjService _service;

  CnpjState _state = CnpjState.idle;
  CnpjModel? _cnpj;
  String? _errorMessage;

  CnpjController({CnpjService? service})
      : _service = service ?? CnpjService();

  CnpjState get state => _state;
  CnpjModel? get cnpj => _cnpj;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CnpjState.loading;

  Future<void> consultar(String cnpj) async {
    if (cnpj.replaceAll(RegExp(r'[.\-/\s]'), '').length != 14) {
      _errorMessage = 'CNPJ deve conter 14 dígitos.';
      _state = CnpjState.error;
      notifyListeners();
      return;
    }

    _state = CnpjState.loading;
    _cnpj = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _cnpj = await _service.consultar(cnpj);
      _state = CnpjState.success;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      _state = CnpjState.error;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _state = CnpjState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = CnpjState.idle;
    _cnpj = null;
    _errorMessage = null;
    notifyListeners();
  }
}
