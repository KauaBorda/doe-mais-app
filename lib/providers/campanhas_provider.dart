import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/campanha.dart';
import '../services/campanha_service.dart';

class CampanhasProvider extends ChangeNotifier {
  CampanhasProvider({CampanhaService? service}) : _service = service ?? CampanhaService();

  final CampanhaService _service;

  bool isLoading = false;
  String? error;
  List<CampanhaResumo> campanhas = [];

  Future<void> carregar() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      campanhas = await _service.listarAtivas();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
