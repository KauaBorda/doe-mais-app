class CategoriaDoacao {
  final int idCategoria;
  final String nome;
  final String? descricao;

  CategoriaDoacao({required this.idCategoria, required this.nome, this.descricao});

  factory CategoriaDoacao.fromJson(Map<String, dynamic> json) {
    return CategoriaDoacao(
      idCategoria: json['idCategoria'] as int,
      nome: json['nome'] as String? ?? '',
      descricao: json['descricao'] as String?,
    );
  }
}
