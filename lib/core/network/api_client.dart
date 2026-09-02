import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';

/// Base URL da API `api-doacao` (Spring Boot, porta 8080, sem prefixo de path).
///
/// Pode ser sobrescrita em tempo de build, por exemplo para testar em um
/// device físico apontando para o IP da máquina que roda a API:
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
String _defaultBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  if (kIsWeb) return 'http://localhost:8080';
  if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // emulador Android
  return 'http://localhost:8080'; // iOS simulator / desktop
}

class ApiClient {
  ApiClient._internal() : dio = Dio(
          BaseOptions(
            baseUrl: _defaultBaseUrl(),
            connectTimeout: const Duration(seconds: 12),
            receiveTimeout: const Duration(seconds: 12),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  static final ApiClient instance = ApiClient._internal();

  final Dio dio;

  /// Uploads (`/uploads/**`) são servidos pela própria API como caminhos
  /// relativos — prefixa com a baseUrl configurada, igual ao `prefixUrl` do
  /// FrontDoe- (`services/api.ts`).
  static String? resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${instance.dio.options.baseUrl}$url';
  }

  /// Converte qualquer erro de rede/HTTP em uma [ApiException] com mensagem
  /// amigável, priorizando a mensagem de erro devolvida pela API
  /// (`GlobalExceptionHandler` do backend costuma expor `message`/`mensagem`).
  static ApiException toApiException(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      String? backendMessage;
      if (data is Map) {
        backendMessage = (data['message'] ?? data['mensagem'])?.toString();
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
              'Tempo de conexão esgotado. Verifique se a API está no ar e acessível.');
        case DioExceptionType.connectionError:
          return ApiException(
              'Não foi possível conectar à API. Verifique sua conexão e o endereço configurado.');
        default:
          return ApiException(
            backendMessage ?? 'Ocorreu um erro ao comunicar com o servidor.',
            statusCode: error.response?.statusCode,
          );
      }
    }
    return ApiException(error.toString());
  }
}
