import 'formatters.dart';

class Validators {
  Validators._();

  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static String? required(String? value, {String message = 'Campo obrigatório'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    if (!_emailRegex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  static String? cpfCnpj(String? value) {
    final digits = Formatters.onlyDigits(value ?? '');
    if (digits.length != 11 && digits.length != 14) {
      return 'CPF (11 dígitos) ou CNPJ (14 dígitos) inválido';
    }
    return null;
  }
}
