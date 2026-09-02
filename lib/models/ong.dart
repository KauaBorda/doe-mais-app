class Ong {
  final int idOng;
  final String? razaoSocial;
  final String? nomeFantasia;
  final String? email;
  final String? telefone;
  final String? cidade;
  final String? estado;
  final String? areaAtuacao;
  final String? logoUrl;

  Ong({
    required this.idOng,
    this.razaoSocial,
    this.nomeFantasia,
    this.email,
    this.telefone,
    this.cidade,
    this.estado,
    this.areaAtuacao,
    this.logoUrl,
  });

  String get nomeExibicao =>
      (nomeFantasia?.isNotEmpty ?? false) ? nomeFantasia! : (razaoSocial ?? 'ONG');

  factory Ong.fromJson(Map<String, dynamic> json) {
    return Ong(
      idOng: json['idOng'] as int,
      razaoSocial: json['razaoSocial'] as String?,
      nomeFantasia: json['nomeFantasia'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      areaAtuacao: json['areaAtuacao'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
