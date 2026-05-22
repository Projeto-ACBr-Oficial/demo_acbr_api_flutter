import 'package:flutter/foundation.dart';
import '../core/exceptions/api_exception.dart';
import '../models/cep/cep_model.dart';
import '../services/cep_service.dart';

enum CepState { idle, loading, success, error }

class CepController extends ChangeNotifier {
  final CepService _service;

  CepState _state = CepState.idle;
  CepModel? _cep;
  String? _errorMessage;

  CepController({CepService? service}) : _service = service ?? CepService();

  CepState get state => _state;
  CepModel? get cep => _cep;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CepState.loading;

  Future<void> consultar(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[.\-\s]'), '');
    if (cepLimpo.length != 8) {
      _errorMessage = 'CEP deve conter 8 dígitos.';
      _state = CepState.error;
      notifyListeners();
      return;
    }

    _state = CepState.loading;
    _cep = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _cep = await _service.consultar(cepLimpo);
      _state = CepState.success;
    } on ApiException catch (e) {
      _errorMessage = e.userMessage;
      _state = CepState.error;
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _state = CepState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = CepState.idle;
    _cep = null;
    _errorMessage = null;
    notifyListeners();
  }
}
