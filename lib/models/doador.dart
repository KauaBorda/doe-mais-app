class Doador {
  final int idDoador;
  final String tipoDoador;
  final String nome;
  final String? cpfCnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? fotoUrl;

  Doador({
    required this.idDoador,
    required this.tipoDoador,
    required this.nome,
    this.cpfCnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.cep,
    this.fotoUrl,
  });

  factory Doador.fromJson(Map<String, dynamic> json) {
    return Doador(
      idDoador: json['idDoador'] as int,
      tipoDoador: json['tipoDoador'] as String? ?? 'pessoa_fisica',
      nome: json['nome'] as String? ?? '',
      cpfCnpj: json['cpfCnpj'] as String?,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      endereco: json['endereco'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      cep: json['cep'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'tipoDoador': tipoDoador,
        'nome': nome,
        'cpfCnpj': cpfCnpj,
        'email': email,
        'telefone': telefone,
        'endereco': endereco,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'cep': cep,
      };

  Doador copyWith({
    String? nome,
    String? telefone,
    String? endereco,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? fotoUrl,
  }) {
    return Doador(
      idDoador: idDoador,
      tipoDoador: tipoDoador,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj,
      email: email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
