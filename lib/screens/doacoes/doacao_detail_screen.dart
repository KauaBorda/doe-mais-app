import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/doacao.dart';
import '../../services/doacao_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';

class DoacaoDetailScreen extends StatefulWidget {
  const DoacaoDetailScreen({super.key, required this.doacao});

  final Doacao doacao;

  @override
  State<DoacaoDetailScreen> createState() => _DoacaoDetailScreenState();
}

class _DoacaoDetailScreenState extends State<DoacaoDetailScreen> {
  final _service = DoacaoService();
  List<DoacaoItem> _itens = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!widget.doacao.isFinanceira) _carregarItens();
  }

  Future<void> _carregarItens() async {
    setState(() => _isLoading = true);
    try {
      final itens = await _service.listarItensDaDoacao(widget.doacao.idDoacao);
      if (!mounted) return;
      setState(() => _itens = itens);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doacao = widget.doacao;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da doação')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doacao.tituloCampanha ?? 'Doação direta',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text('para ${doacao.nomeOng}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  _Row(label: 'Data', value: Formatters.dateTime(doacao.dataDoacao)),
                  _Row(label: 'Tipo', value: doacao.isFinanceira ? 'Financeira' : 'Material'),
                  _Row(label: 'Status', value: doacao.statusDoacao),
                  if (doacao.isFinanceira)
                    _Row(label: 'Valor', value: Formatters.currency(doacao.valorTotal)),
                  if (doacao.descricaoGeral != null && doacao.descricaoGeral!.isNotEmpty)
                    _Row(label: 'Descrição', value: doacao.descricaoGeral!),
                  if (doacao.observacoes != null && doacao.observacoes!.isNotEmpty)
                    _Row(label: 'Observações', value: doacao.observacoes!),
                ],
              ),
            ),
          ),
          if (!doacao.isFinanceira) ...[
            const SizedBox(height: 20),
            const Text('Itens doados',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            if (_isLoading)
              const LoadingView()
            else if (_error != null)
              EmptyState(icon: Icons.error_outline_rounded, title: 'Erro ao carregar itens', subtitle: _error)
            else if (_itens.isEmpty)
              const EmptyState(icon: Icons.inventory_2_outlined, title: 'Nenhum item encontrado')
            else
              ..._itens.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(item.nomeItem,
                          style: const TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        '${item.quantidade.toStringAsFixed(item.quantidade.truncateToDouble() == item.quantidade ? 0 : 2)} ${item.unidadeMedida}'
                        '${item.estadoItem != null ? ' · ${item.estadoItem}' : ''}'
                        '${item.validade != null ? ' · val: ${Formatters.date(item.validade)}' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
