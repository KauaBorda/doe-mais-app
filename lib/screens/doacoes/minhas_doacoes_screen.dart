import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/doacao.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doacoes_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'doacao_detail_screen.dart';

class MinhasDoacoesScreen extends StatefulWidget {
  const MinhasDoacoesScreen({super.key});

  @override
  State<MinhasDoacoesScreen> createState() => _MinhasDoacoesScreenState();
}

class _MinhasDoacoesScreenState extends State<MinhasDoacoesScreen> {
  late final DoacoesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DoacoesProvider();
    _carregar();
  }

  Future<void> _carregar() async {
    final idDoador = context.read<AuthProvider>().session?.idDoador;
    if (idDoador != null) await _provider.carregar(idDoador);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Minhas doações')),
        body: Consumer<DoacoesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.doacoes.isEmpty) {
              return const LoadingView();
            }
            if (provider.error != null && provider.doacoes.isEmpty) {
              return EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Não foi possível carregar suas doações',
                subtitle: provider.error,
                actionLabel: 'Tentar novamente',
                onAction: _carregar,
              );
            }
            if (provider.doacoes.isEmpty) {
              return const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Você ainda não fez nenhuma doação',
                subtitle: 'Explore as campanhas ativas e faça sua primeira doação.',
              );
            }
            return RefreshIndicator(
              onRefresh: _carregar,
              color: AppColors.accentPink,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.doacoes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _DoacaoTile(doacao: provider.doacoes[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DoacaoTile extends StatelessWidget {
  const _DoacaoTile({required this.doacao});

  final Doacao doacao;

  @override
  Widget build(BuildContext context) {
    final isFinanceira = doacao.isFinanceira;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DoacaoDetailScreen(doacao: doacao)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isFinanceira ? AppColors.button : AppColors.success)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFinanceira ? Icons.attach_money_rounded : Icons.inventory_2_outlined,
                  color: isFinanceira ? AppColors.button : AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doacao.tituloCampanha ?? doacao.nomeOng,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(doacao.dataDoacao),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isFinanceira && doacao.valorTotal != null)
                    Text(
                      Formatters.currency(doacao.valorTotal),
                      style: const TextStyle(
                          color: AppColors.accentPink, fontWeight: FontWeight.w700),
                    )
                  else
                    const Text('Material',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  _StatusBadge(status: doacao.statusDoacao),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentPurple.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: AppColors.accentPurple, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
