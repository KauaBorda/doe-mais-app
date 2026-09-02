import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/categoria_doacao.dart';
import '../models/doacao.dart';
import '../models/item_doacao.dart';

class DoacaoService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<CategoriaDoacao>> listarCategorias() async {
    try {
      final response = await _dio.get('/categorias');
      final list = response.data as List;
      return list.map((e) => CategoriaDoacao.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<List<ItemDoacao>> listarItensPorCategoria(int idCategoria) async {
    try {
      final response = await _dio.get('/categorias/$idCategoria/itens');
      final list = response.data as List;
      return list.map((e) => ItemDoacao.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Doacao> registrarFinanceira({
    required int idDoador,
    required int idOng,
    required int idCampanha,
    required double valor,
    String? mensagem,
  }) async {
    try {
      final response = await _dio.post('/doacoes', data: {
        'idDoador': idDoador,
        'idOng': idOng,
        'idCampanha': idCampanha,
        'tipoDoacao': 'financeira',
        'valorTotal': valor,
        if (mensagem != null && mensagem.isNotEmpty) 'observacoes': mensagem,
      });
      return Doacao.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<Doacao> registrarMaterial({
    required int idDoador,
    required int idOng,
    required int idCampanha,
    required String descricaoGeral,
    String? observacoes,
    required List<ItemDoacaoSelecionado> itens,
  }) async {
    try {
      final response = await _dio.post('/doacoes', data: {
        'idDoador': idDoador,
        'idOng': idOng,
        'idCampanha': idCampanha,
        'tipoDoacao': 'material',
        'descricaoGeral': descricaoGeral,
        if (observacoes != null && observacoes.isNotEmpty) 'observacoes': observacoes,
        'itens': itens.map((e) => e.toRequestJson()).toList(),
      });
      return Doacao.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<List<DoacaoItem>> listarItensDaDoacao(int idDoacao) async {
    try {
      final response = await _dio.get('/doacoes/$idDoacao/itens');
      final list = response.data as List;
      return list.map((e) => DoacaoItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
