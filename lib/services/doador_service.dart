import 'dart:io';

import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/doacao.dart';
import '../models/doador.dart';

class DoadorService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Doador> registrar({
    required String tipoDoador,
    required String nome,
    required String email,
    required String senha,
    required String cpfCnpj,
    String? telefone,
  }) async {
    try {
      final response = await _dio.post('/doadores', data: {
        'tipoDoador': tipoDoador,
        'nome': nome,
        'email': email,
        'senha': senha,
        'cpfCnpj': cpfCnpj,
        if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
      });
      return Doador.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Doador> buscarPorId(int idDoador) async {
    try {
      final response = await _dio.get('/doadores/$idDoador');
      return Doador.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Doador> atualizar(Doador doador) async {
    try {
      final response =
          await _dio.put('/doadores/${doador.idDoador}', data: doador.toRequestJson());
      return Doador.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Doador> atualizarFoto(int idDoador, File arquivo) async {
    try {
      final formData = FormData.fromMap({
        'arquivo': await MultipartFile.fromFile(arquivo.path),
      });
      final response = await _dio.post('/doadores/$idDoador/foto', data: formData);
      return Doador.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<List<Doacao>> listarDoacoes(int idDoador) async {
    try {
      final response = await _dio.get('/doadores/$idDoador/doacoes');
      final list = response.data as List;
      return list
          .map((e) => Doacao.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => (b.dataDoacao ?? DateTime(0))
            .compareTo(a.dataDoacao ?? DateTime(0)));
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
