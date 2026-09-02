import 'package:flutter/foundation.dart';

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value as String);
}

double? _parseDecimal(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// `CampanhaResumoDTO` — usado nas listagens (`GET /campanhas/ativas` etc).
@immutable
class CampanhaResumo {
  final int idCampanha;
  final String tipoCampanha;
  final String titulo;
  final String? imagemUrl;
  final double? metaFinanceira;
  final double valorArrecadado;
  final String status;
  final String? categoria;
  final DateTime? dataFim;
  final int quantidadeDoadores;

  const CampanhaResumo({
    required this.idCampanha,
    required this.tipoCampanha,
    required this.titulo,
    this.imagemUrl,
    this.metaFinanceira,
    required this.valorArrecadado,
    required this.status,
    this.categoria,
    this.dataFim,
    required this.quantidadeDoadores,
  });

  double get progresso {
    if (metaFinanceira == null || metaFinanceira == 0) return 0;
    final p = valorArrecadado / metaFinanceira!;
    return p.clamp(0, 1).toDouble();
  }

  factory CampanhaResumo.fromJson(Map<String, dynamic> json) {
    return CampanhaResumo(
      idCampanha: json['idCampanha'] as int,
      tipoCampanha: json['tipoCampanha'] as String? ?? 'financeira',
      titulo: json['titulo'] as String? ?? '',
      imagemUrl: json['imagemUrl'] as String?,
      metaFinanceira: _parseDecimal(json['metaFinanceira']),
      valorArrecadado: _parseDecimal(json['valorArrecadado']) ?? 0,
      status: json['status'] as String? ?? 'ativa',
      categoria: json['categoria'] as String?,
      dataFim: _parseDate(json['dataFim']),
      quantidadeDoadores: json['quantidadeDoadores'] as int? ?? 0,
    );
  }
}

/// `CampanhaResponseDTO` — detalhe completo (`GET /campanhas/{id}`).
@immutable
class CampanhaDetalhe {
  final int idCampanha;
  final int idOng;
  final String nomeOng;
  final String tipoCampanha;
  final String titulo;
  final String descricao;
  final String? objetivo;
  final double? metaFinanceira;
  final double valorArrecadado;
  final String? imagemUrl;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String status;
  final String? categoria;
  final String? localizacao;
  final int quantidadeDoadores;
  final int visualizacoes;

  const CampanhaDetalhe({
    required this.idCampanha,
    required this.idOng,
    required this.nomeOng,
    required this.tipoCampanha,
    required this.titulo,
    required this.descricao,
    this.objetivo,
    this.metaFinanceira,
    required this.valorArrecadado,
    this.imagemUrl,
    this.dataInicio,
    this.dataFim,
    required this.status,
    this.categoria,
    this.localizacao,
    required this.quantidadeDoadores,
    required this.visualizacoes,
  });

  double get progresso {
    if (metaFinanceira == null || metaFinanceira == 0) return 0;
    final p = valorArrecadado / metaFinanceira!;
    return p.clamp(0, 1).toDouble();
  }

  bool get aceitaFinanceira =>
      tipoCampanha == 'financeira' || tipoCampanha == 'ambas';
  bool get aceitaMaterial => tipoCampanha == 'material' || tipoCampanha == 'ambas';

  factory CampanhaDetalhe.fromJson(Map<String, dynamic> json) {
    return CampanhaDetalhe(
      idCampanha: json['idCampanha'] as int,
      idOng: json['idOng'] as int,
      nomeOng: json['nomeOng'] as String? ?? 'ONG',
      tipoCampanha: json['tipoCampanha'] as String? ?? 'financeira',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      objetivo: json['objetivo'] as String?,
      metaFinanceira: _parseDecimal(json['metaFinanceira']),
      valorArrecadado: _parseDecimal(json['valorArrecadado']) ?? 0,
      imagemUrl: json['imagemUrl'] as String?,
      dataInicio: _parseDate(json['dataInicio']),
      dataFim: _parseDate(json['dataFim']),
      status: json['status'] as String? ?? 'ativa',
      categoria: json['categoria'] as String?,
      localizacao: json['localizacao'] as String?,
      quantidadeDoadores: json['quantidadeDoadores'] as int? ?? 0,
      visualizacoes: (json['visualizacoes'] as num?)?.toInt() ?? 0,
    );
  }
}
