/// Representa a entidade `Doacao` devolvida crua pela API (não há um DTO de
/// resposta dedicado para doações — `GET /doacoes`, `GET /doadores/{id}/doacoes`
/// e `POST /doacoes` devolvem o próprio objeto JPA, com `ong`/`campanha` aninhados).
class Doacao {
  final int idDoacao;
  final DateTime? dataDoacao;
  final String tipoDoacao;
  final String? descricaoGeral;
  final double? valorTotal;
  final String statusDoacao;
  final String? observacoes;
  final int idOng;
  final String nomeOng;
  final int? idCampanha;
  final String? tituloCampanha;

  Doacao({
    required this.idDoacao,
    this.dataDoacao,
    required this.tipoDoacao,
    this.descricaoGeral,
    this.valorTotal,
    required this.statusDoacao,
    this.observacoes,
    required this.idOng,
    required this.nomeOng,
    this.idCampanha,
    this.tituloCampanha,
  });

  bool get isFinanceira => tipoDoacao == 'financeira';

  factory Doacao.fromJson(Map<String, dynamic> json) {
    final ong = json['ong'] as Map<String, dynamic>?;
    final campanha = json['campanha'] as Map<String, dynamic>?;
    final nomeFantasia = ong?['nomeFantasia'] as String?;
    final razaoSocial = ong?['razaoSocial'] as String?;

    return Doacao(
      idDoacao: json['idDoacao'] as int,
      dataDoacao: json['dataDoacao'] != null
          ? DateTime.tryParse(json['dataDoacao'] as String)
          : null,
      tipoDoacao: json['tipoDoacao'] as String? ?? 'financeira',
      descricaoGeral: json['descricaoGeral'] as String?,
      valorTotal: (json['valorTotal'] as num?)?.toDouble(),
      statusDoacao: json['statusDoacao'] as String? ?? 'recebida',
      observacoes: json['observacoes'] as String?,
      idOng: ong?['idOng'] as int? ?? 0,
      nomeOng: (nomeFantasia?.isNotEmpty ?? false)
          ? nomeFantasia!
          : (razaoSocial ?? 'ONG'),
      idCampanha: campanha?['idCampanha'] as int?,
      tituloCampanha: campanha?['titulo'] as String?,
    );
  }
}

class DoacaoItem {
  final int idDoacaoItem;
  final String nomeItem;
  final String unidadeMedida;
  final double quantidade;
  final double? valorUnitario;
  final DateTime? validade;
  final String? estadoItem;
  final String? observacoes;

  DoacaoItem({
    required this.idDoacaoItem,
    required this.nomeItem,
    required this.unidadeMedida,
    required this.quantidade,
    this.valorUnitario,
    this.validade,
    this.estadoItem,
    this.observacoes,
  });

  factory DoacaoItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    return DoacaoItem(
      idDoacaoItem: json['idDoacaoItem'] as int,
      nomeItem: item?['nome'] as String? ?? '-',
      unidadeMedida: item?['unidadeMedida'] as String? ?? 'un',
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 0,
      valorUnitario: (json['valorUnitario'] as num?)?.toDouble(),
      validade: json['validade'] != null
          ? DateTime.tryParse(json['validade'] as String)
          : null,
      estadoItem: json['estadoItem'] as String?,
      observacoes: json['observacoes'] as String?,
    );
  }
}
