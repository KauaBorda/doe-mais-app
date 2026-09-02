import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  static final _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateTime = DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR');

  static String currency(num? value) => _currency.format(value ?? 0);

  static String date(DateTime? value) {
    if (value == null) return '-';
    return _date.format(value);
  }

  static String dateTime(DateTime? value) {
    if (value == null) return '-';
    return _dateTime.format(value);
  }

  /// Aplica máscara de CPF (000.000.000-00) ou CNPJ (00.000.000/0000-00)
  /// conforme a quantidade de dígitos, igual ao comportamento do FrontDoe-.
  static String maskCpfCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 14 ? digits.substring(0, 14) : digits;

    if (truncated.length <= 11) {
      var out = truncated;
      out = out.replaceFirstMapped(
          RegExp(r'^(\d{3})(\d)'), (m) => '${m[1]}.${m[2]}');
      out = out.replaceFirstMapped(
          RegExp(r'^(\d{3})\.(\d{3})(\d)'), (m) => '${m[1]}.${m[2]}.${m[3]}');
      out = out.replaceFirstMapped(
          RegExp(r'\.(\d{3})(\d)'), (m) => '.${m[1]}-${m[2]}');
      return out;
    }

    var out = truncated;
    out = out.replaceFirstMapped(
        RegExp(r'^(\d{2})(\d)'), (m) => '${m[1]}.${m[2]}');
    out = out.replaceFirstMapped(
        RegExp(r'^(\d{2})\.(\d{3})(\d)'), (m) => '${m[1]}.${m[2]}.${m[3]}');
    out = out.replaceFirstMapped(
        RegExp(r'\.(\d{3})(\d)'), (m) => '.${m[1]}/${m[2]}');
    out = out.replaceFirstMapped(
        RegExp(r'(\d{4})(\d)'), (m) => '${m[1]}-${m[2]}');
    return out;
  }

  static String onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');
}
