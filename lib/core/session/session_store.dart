import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/doador_session.dart';

/// Persiste a sessão do doador localmente, no mesmo espírito do
/// `localStorage` usado pelo `FrontDoe-` — a API não emite token, então
/// aqui apenas guardamos os dados retornados no login/registro.
class SessionStore {
  static const _key = 'doe_mais_session';

  Future<void> save(DoadorSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<DoadorSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return DoadorSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
