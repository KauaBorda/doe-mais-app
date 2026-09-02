/// Sessão do doador autenticado, mapeada a partir do `LoginResponseDTO`
/// devolvido por `POST /auth/login` (a API não usa token/JWT — apenas
/// confere a credencial e devolve o perfil do usuário).
class DoadorSession {
  final int idUsuario;
  final int? idDoador;
  final String nome;
  final String email;
  final String perfil;

  DoadorSession({
    required this.idUsuario,
    required this.idDoador,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  bool get isDoador => perfil.toLowerCase() == 'doador';

  factory DoadorSession.fromJson(Map<String, dynamic> json) {
    return DoadorSession(
      idUsuario: json['idUsuario'] as int,
      idDoador: json['idDoador'] as int?,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      perfil: json['perfil'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'idUsuario': idUsuario,
        'idDoador': idDoador,
        'nome': nome,
        'email': email,
        'perfil': perfil,
      };
}
