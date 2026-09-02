import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/campanha.dart';
import '../../services/campanha_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_bar.dart';
import '../doacao/doacao_financeira_sheet.dart';
import '../doacao/doacao_material_sheet.dart';

class CampanhaDetailScreen extends StatefulWidget {
  const CampanhaDetailScreen({super.key, required this.idCampanha});

  final int idCampanha;

  @override
  State<CampanhaDetailScreen> createState() => _CampanhaDetailScreenState();
}

class _CampanhaDetailScreenState extends State<CampanhaDetailScreen> {
  final _service = CampanhaService();
  CampanhaDetalhe? _campanha;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final campanha = await _service.buscarPorId(widget.idCampanha);
      if (!mounted) return;
      setState(() => _campanha = campanha);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _abrirDoacao() {
    final campanha = _campanha;
    if (campanha == null) return;

    if (campanha.aceitaFinanceira && campanha.aceitaMaterial) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _EscolherTipoSheet(
          onFinanceira: () {
            Navigator.pop(context);
            _abrirFinanceira(campanha);
          },
          onMaterial: () {
            Navigator.pop(context);
            _abrirMaterial(campanha);
          },
        ),
      );
    } else if (campanha.aceitaFinanceira) {
      _abrirFinanceira(campanha);
    } else {
      _abrirMaterial(campanha);
    }
  }

  void _abrirFinanceira(CampanhaDetalhe campanha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DoacaoFinanceiraSheet(
        campanha: campanha,
        onDoacaoRealizada: _carregar,
      ),
    );
  }

  void _abrirMaterial(CampanhaDetalhe campanha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DoacaoMaterialSheet(
        campanha: campanha,
        onDoacaoRealizada: _carregar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _campanha == null) {
      return const Scaffold(body: LoadingView());
    }
    if (_error != null && _campanha == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Não foi possível carregar a campanha',
          subtitle: _error,
          actionLabel: 'Tentar novamente',
          onAction: _carregar,
        ),
      );
    }

    final campanha = _campanha!;
    final imagemUrl = ApiClient.resolveUrl(campanha.imagemUrl);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: imagemUrl != null
                  ? Image.network(
                      imagemUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppColors.bgSecondary),
                    )
                  : Container(
                      color: AppColors.bgSecondary,
                      alignment: Alignment.center,
                      child: const Icon(Icons.volunteer_activism_rounded,
                          size: 64, color: AppColors.textSecondary),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campanha.nomeOng,
                    style: const TextStyle(
                      color: AppColors.accentPink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    campanha.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (campanha.metaFinanceira != null) ...[
                    AppProgressBar(progress: campanha.progresso, height: 10),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Formatters.currency(campanha.valorArrecadado)} arrecadados',
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'meta ${Formatters.currency(campanha.metaFinanceira)}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                          icon: Icons.people_alt_rounded,
                          label: '${campanha.quantidadeDoadores} doadores'),
                      if (campanha.localizacao != null)
                        _InfoChip(
                            icon: Icons.location_on_outlined, label: campanha.localizacao!),
                      if (campanha.dataFim != null)
                        _InfoChip(
                            icon: Icons.event_outlined,
                            label: 'até ${Formatters.date(campanha.dataFim)}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Sobre a campanha',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(campanha.descricao,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  if (campanha.objetivo != null && campanha.objetivo!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Objetivo',
                        style: TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(campanha.objetivo!,
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: campanha.status == 'ativa'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  label: 'Doar para esta campanha',
                  icon: Icons.favorite_rounded,
                  onPressed: _abrirDoacao,
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

class _EscolherTipoSheet extends StatelessWidget {
  const _EscolherTipoSheet({required this.onFinanceira, required this.onMaterial});

  final VoidCallback onFinanceira;
  final VoidCallback onMaterial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Qual tipo de doação você deseja fazer?',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _OpcaoTipo(
                    icon: Icons.attach_money_rounded,
                    label: 'Financeira',
                    subtitle: 'Doação em dinheiro',
                    color: AppColors.button,
                    onTap: onFinanceira,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OpcaoTipo(
                    icon: Icons.inventory_2_outlined,
                    label: 'Material',
                    subtitle: 'Roupas, alimentos...',
                    color: AppColors.success,
                    onTap: onMaterial,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoTipo extends StatelessWidget {
  const _OpcaoTipo({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
