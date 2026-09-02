import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/session/session_store.dart';
import '../models/doador.dart';
import '../models/doador_session.dart';
import '../services/auth_service.dart';
import '../services/doador_service.dart';

enum AuthStatus { checking, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
    DoadorService? doadorService,
    SessionStore? sessionStore,
  })  : _authService = authService ?? AuthService(),
        _doadorService = doadorService ?? DoadorService(),
        _sessionStore = sessionStore ?? SessionStore();

  final AuthService _authService;
  final DoadorService _doadorService;
  final SessionStore _sessionStore;

  AuthStatus status = AuthStatus.checking;
  DoadorSession? session;
  Doador? doador;

  bool get isLoading => status == AuthStatus.checking;

  Future<void> bootstrap() async {
    final stored = await _sessionStore.load();
    if (stored == null || !stored.isDoador || stored.idDoador == null) {
      status = AuthStatus.loggedOut;
      notifyListeners();
      return;
    }
    session = stored;
    try {
      doador = await _doadorService.buscarPorId(stored.idDoador!);
      status = AuthStatus.loggedIn;
    } catch (_) {
      // Sessão local ficou inválida (doador removido, etc.) — volta ao login.
      await _sessionStore.clear();
      session = null;
      status = AuthStatus.loggedOut;
    }
    notifyListeners();
  }

  /// Retorna null em caso de sucesso, ou uma mensagem de erro amigável.
  Future<String?> login({required String email, required String senha}) async {
    try {
      final result = await _authService.login(email: email, senha: senha);
      if (!result.isDoador || result.idDoador == null) {
        return 'Este aplicativo é exclusivo para doadores. ONGs devem usar o painel web.';
      }
      session = result;
      doador = await _doadorService.buscarPorId(result.idDoador!);
      await _sessionStore.save(result);
      status = AuthStatus.loggedIn;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> registrar({
    required String tipoDoador,
    required String nome,
    required String email,
    required String senha,
    required String cpfCnpj,
    String? telefone,
  }) async {
    try {
      final novoDoador = await _doadorService.registrar(
        tipoDoador: tipoDoador,
        nome: nome,
        email: email,
        senha: senha,
        cpfCnpj: cpfCnpj,
        telefone: telefone,
      );

      // A API não devolve o login automaticamente após o cadastro —
      // autenticamos em seguida com as credenciais recém-criadas.
      final loginError = await login(email: email, senha: senha);
      if (loginError != null) return loginError;

      doador = novoDoador;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> refreshDoador() async {
    if (session?.idDoador == null) return;
    doador = await _doadorService.buscarPorId(session!.idDoador!);
    notifyListeners();
  }

  void updateDoador(Doador updated) {
    doador = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _sessionStore.clear();
    session = null;
    doador = null;
    status = AuthStatus.loggedOut;
    notifyListeners();
  }
}
