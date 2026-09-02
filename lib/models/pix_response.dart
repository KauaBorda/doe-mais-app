class PixResponse {
  final int? idDoacao;
  final String pixCopiaECola;
  final String qrCodeBase64;
  final double valor;
  final String? txId;
  final String? mensagem;

  PixResponse({
    this.idDoacao,
    required this.pixCopiaECola,
    required this.qrCodeBase64,
    required this.valor,
    this.txId,
    this.mensagem,
  });

  factory PixResponse.fromJson(Map<String, dynamic> json) {
    return PixResponse(
      idDoacao: json['idDoacao'] as int?,
      pixCopiaECola: json['pixCopiaECola'] as String? ?? '',
      qrCodeBase64: json['qrCodeBase64'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0,
      txId: json['txId'] as String?,
      mensagem: json['mensagem'] as String?,
    );
  }
}
