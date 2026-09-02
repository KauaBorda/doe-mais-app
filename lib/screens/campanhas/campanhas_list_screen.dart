import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/campanha.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campanhas_provider.dart';
import '../../providers/doacoes_provider.dart';
import '../../widgets/campanha_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/stat_card.dart';
import 'campanha_detail_screen.dart';

class CampanhasListScreen extends StatefulWidget {
  const CampanhasListScreen({super.key});

  @override
  State<CampanhasListScreen> createState() => _CampanhasListScreenState();
}

class _CampanhasListScreenState extends State<CampanhasListScreen> {
  late final CampanhasProvider _campanhasProvider;
  late final DoacoesProvider _doacoesProvider;
  final ValueNotifier<int> _tick = ValueNotifier(0);

  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _campanhasProvider = CampanhasProvider()..addListener(_onChange);
    _doacoesProvider = DoacoesProvider()..addListener(_onChange);
    _carregarTudo();
  }

  void _onChange() => _tick.value++;

  Future<void> _carregarTudo() async {
    final idDoador = context.read<AuthProvider>().session?.idDoador;
    await Future.wait([
      _campanhasProvider.carregar(),
      if (idDoador != null) _doacoesProvider.carregar(idDoador),
    ]);
  }

  @override
  void dispose() {
    _campanhasProvider.removeListener(_onChange);
    _doacoesProvider.removeListener(_onChange);
    _campanhasProvider.dispose();
    _doacoesProvider.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doador = context.watch<AuthProvider>().doador;
    final primeiroNome = (doador?.nome ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: _tick,
          builder: (context, _, _) {
            if (_campanhasProvider.isLoading && _campanhasProvider.campanhas.isEmpty) {
              return const LoadingView();
            }
            if (_campanhasProvider.error != null && _campanhasProvider.campanhas.isEmpty) {
              return EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Não foi possível carregar as campanhas',
                subtitle: _campanhasProvider.error,
                actionLabel: 'Tentar novamente',
                onAction: _carregarTudo,
              );
            }

            final categorias = _campanhasProvider.campanhas
                .map((c) => c.categoria)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();

            final destaque = _categoriaSelecionada == null && _campanhasProvider.campanhas.isNotEmpty
                ? _campanhasProvider.campanhas.first
                : null;

            final listaFiltrada = _campanhasProvider.campanhas.where((c) {
              if (destaque != null && c.idCampanha == destaque.idCampanha) return false;
              if (_categoriaSelecionada == null) return true;
              return c.categoria == _categoriaSelecionada;
            }).toList();

            return RefreshIndicator(
              onRefresh: _carregarTudo,
              color: AppColors.accentPink,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(nome: primeiroNome),
                  ),
                  SliverToBoxAdapter(
                    child: _ImpactSection(doacoesProvider: _doacoesProvider),
                  ),
                  if (destaque != null)
                    SliverToBoxAdapter(
                      child: _FeaturedCampaign(
                        campanha: destaque,
                        onTap: () => _abrirDetalhe(destaque.idCampanha),
                      ),
                    ),
                  if (categorias.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _CategoryFilters(
                        categorias: categorias,
                        selecionada: _categoriaSelecionada,
                        onSelect: (c) => setState(() => _categoriaSelecionada = c),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        _categoriaSelecionada == null ? 'Todas as campanhas' : _categoriaSelecionada!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  if (listaFiltrada.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 40),
                      sliver: SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'Nenhuma campanha nessa categoria',
                          subtitle: 'Experimente outra categoria ou volte depois.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: listaFiltrada.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final campanha = listaFiltrada[index];
                          return CampanhaCard(
                            campanha: campanha,
                            onTap: () => _abrirDetalhe(campanha.idCampanha),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _abrirDetalhe(int idCampanha) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CampanhaDetailScreen(idCampanha: idCampanha)))
        .then((_) => _carregarTudo());
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.nome});

  final String nome;

  @override
  Widget build(BuildContext context) {
    final saudacao = nome.isEmpty ? 'Olá!' : 'Olá, $nome!';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: AppColors.logoGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saudacao,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Vamos fazer a diferença hoje?',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection({required this.doacoesProvider});

  final DoacoesProvider doacoesProvider;

  @override
  Widget build(BuildContext context) {
    final doacoes = doacoesProvider.doacoes;

    if (doacoesProvider.isLoading && doacoes.isEmpty) {
      return const SizedBox.shrink();
    }

    if (doacoes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentPurple.withValues(alpha: 0.18),
                AppColors.accentPink.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.celebration_rounded, color: AppColors.accentPink, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Você ainda não fez nenhuma doação',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Escolha uma causa aqui embaixo e comece agora.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalDoado = doacoes
        .where((d) => d.isFinanceira)
        .fold<double>(0, (sum, d) => sum + (d.valorTotal ?? 0));
    final campanhasApoiadas = doacoes.map((d) => d.idCampanha).whereType<int>().toSet().length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.volunteer_activism_rounded,
              value: '${doacoes.length}',
              label: 'Doações feitas',
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.favorite_rounded,
              value: Formatters.currency(totalDoado),
              label: 'Valor doado',
              color: AppColors.accentPink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.flag_rounded,
              value: '$campanhasApoiadas',
              label: 'Causas apoiadas',
              color: AppColors.button,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCampaign extends StatelessWidget {
  const _FeaturedCampaign({required this.campanha, required this.onTap});

  final CampanhaResumo campanha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imagemUrl = ApiClient.resolveUrl(campanha.imagemUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: imagemUrl != null
                ? DecorationImage(image: NetworkImage(imagemUrl), fit: BoxFit.cover)
                : null,
            gradient: imagemUrl == null ? AppColors.buttonGradient : null,
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✨ Campanha em destaque',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campanha.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (campanha.metaFinanceira != null) ...[
                      AppProgressBar(progress: campanha.progresso, height: 6),
                      const SizedBox(height: 6),
                      Text(
                        '${Formatters.currency(campanha.valorArrecadado)} de ${Formatters.currency(campanha.metaFinanceira)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ] else
                      Text(
                        '${campanha.quantidadeDoadores} pessoas já ajudaram — seja a próxima',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categorias,
    required this.selecionada,
    required this.onSelect,
  });

  final List<String> categorias;
  final String? selecionada;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(label: 'Todas', selected: selecionada == null, onTap: () => onSelect(null)),
          ...categorias.map(
            (c) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: c,
                selected: selecionada == c,
                onTap: () => onSelect(c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentPurple : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accentPurple : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
