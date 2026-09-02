import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/pix_response.dart';

class PixService {
  final Dio _dio = ApiClient.instance.dio;

  Future<PixResponse> buscarPixDaDoacao(int idDoacao) async {
    try {
      final response = await _dio.get('/pix/doacao/$idDoacao');
      return PixResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
