import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/campanha.dart';

class CampanhaService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<CampanhaResumo>> listarAtivas() async {
    try {
      final response = await _dio.get('/campanhas/ativas');
      final list = response.data as List;
      return list.map((e) => CampanhaResumo.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<CampanhaDetalhe> buscarPorId(int id) async {
    try {
      final response = await _dio.get('/campanhas/$id');
      return CampanhaDetalhe.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
