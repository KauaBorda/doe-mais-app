import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/campanha.dart';
import '../../models/doacao.dart';
import '../../models/pix_response.dart';
import '../../providers/auth_provider.dart';
import '../../services/doacao_service.dart';
import '../../services/pix_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'pix_result_sheet.dart';

const _quickValues = [10, 25, 50, 100, 250, 500];

class DoacaoFinanceiraSheet extends StatefulWidget {
  const DoacaoFinanceiraSheet({
    super.key,
    required this.campanha,
    required this.onDoacaoRealizada,
  });

  final CampanhaDetalhe campanha;
  final VoidCallback onDoacaoRealizada;

  @override
  State<DoacaoFinanceiraSheet> createState() => _DoacaoFinanceiraSheetState();
}

class _DoacaoFinanceiraSheetState extends State<DoacaoFinanceiraSheet> {
  final _doacaoService = DoacaoService();
  final _pixService = PixService();
  final _valorController = TextEditingController();
  final _mensagemController = TextEditingController();

  int? _valorRapido;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _valorController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  void _selecionarValorRapido(int valor) {
    setState(() {
      _valorRapido = valor;
      _valorController.text = valor.toString();
    });
  }

  Future<void> _confirmar() async {
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null || valor < 1) {
      setState(() => _error = 'Informe um valor válido (mínimo R\$1)');
      return;
    }

    final auth = context.read<AuthProvider>();
    final idDoador = auth.session?.idDoador;
    if (idDoador == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Doacao doacao = await _doacaoService.registrarFinanceira(
        idDoador: idDoador,
        idOng: widget.campanha.idOng,
        idCampanha: widget.campanha.idCampanha,
        valor: valor,
        mensagem: _mensagemController.text.trim(),
      );

      widget.onDoacaoRealizada();

      PixResponse? pix;
      String? pixError;
      try {
        pix = await _pixService.buscarPixDaDoacao(doacao.idDoacao);
      } on ApiException catch (e) {
        pixError = e.message;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => PixResultSheet(pix: pix, error: pixError),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money_rounded, color: AppColors.accentPink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.campanha.titulo,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              _ErrorBox(message: _error!),
              const SizedBox(height: 16),
            ],
            const Text('Escolha um valor',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: _quickValues.map((v) {
                final selected = _valorRapido == v;
                return OutlinedButton(
                  onPressed: () => _selecionarValorRapido(v),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        selected ? AppColors.accentPurple.withValues(alpha: 0.18) : null,
                    side: BorderSide(
                      color: selected ? AppColors.accentPurple : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(Formatters.currency(v),
                      style: TextStyle(
                          color: selected ? AppColors.accentPurple : AppColors.textPrimary)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Ou insira outro valor (R\$)',
              controller: _valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _valorRapido = null),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Mensagem (opcional)',
              controller: _mensagemController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Confirmar doação',
              icon: Icons.favorite_rounded,
              isLoading: _isLoading,
              onPressed: _confirmar,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }
}
