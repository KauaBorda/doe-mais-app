class ItemDoacao {
  final int idItem;
  final int idCategoria;
  final String nome;
  final String? descricao;
  final String unidadeMedida;
  final bool perecivel;

  ItemDoacao({
    required this.idItem,
    required this.idCategoria,
    required this.nome,
    this.descricao,
    required this.unidadeMedida,
    required this.perecivel,
  });

  factory ItemDoacao.fromJson(Map<String, dynamic> json) {
    final categoria = json['categoria'] as Map<String, dynamic>?;
    return ItemDoacao(
      idItem: json['idItem'] as int,
      idCategoria: categoria?['idCategoria'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String?,
      unidadeMedida: json['unidadeMedida'] as String? ?? 'un',
      perecivel: json['perecivel'] as bool? ?? false,
    );
  }
}

/// Estado de conservação de um item doado, usado no formulário de doação
/// material — mesmas opções do FrontDoe- (`DonationModal.tsx`).
enum EstadoItem { novo, usadoBom, usadoRegular }

extension EstadoItemX on EstadoItem {
  String get valorApi => switch (this) {
        EstadoItem.novo => 'novo',
        EstadoItem.usadoBom => 'usado_bom',
        EstadoItem.usadoRegular => 'usado_regular',
      };

  String get label => switch (this) {
        EstadoItem.novo => 'Novo',
        EstadoItem.usadoBom => 'Usado — bom estado',
        EstadoItem.usadoRegular => 'Usado — estado regular',
      };
}

/// Um item já adicionado à lista da doação material em andamento no app
/// (antes de enviar para a API).
class ItemDoacaoSelecionado {
  final ItemDoacao item;
  final double quantidade;
  final EstadoItem estado;
  final DateTime? validade;
  final String? observacoes;

  ItemDoacaoSelecionado({
    required this.item,
    required this.quantidade,
    required this.estado,
    this.validade,
    this.observacoes,
  });

  Map<String, dynamic> toRequestJson() => {
        'idItem': item.idItem,
        'quantidade': quantidade,
        'estadoItem': estado.valorApi,
        if (validade != null)
          'validade':
              '${validade!.year.toString().padLeft(4, '0')}-${validade!.month.toString().padLeft(2, '0')}-${validade!.day.toString().padLeft(2, '0')}',
        if (observacoes != null && observacoes!.isNotEmpty) 'observacoes': observacoes,
      };
}
