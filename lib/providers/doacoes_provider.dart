import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/doacao.dart';
import '../services/doador_service.dart';

class DoacoesProvider extends ChangeNotifier {
  DoacoesProvider({DoadorService? service}) : _service = service ?? DoadorService();

  final DoadorService _service;

  bool isLoading = false;
  String? error;
  List<Doacao> doacoes = [];

  Future<void> carregar(int idDoador) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      doacoes = await _service.listarDoacoes(idDoador);
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
