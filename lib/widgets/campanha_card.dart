import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/campanha.dart';
import 'progress_bar.dart';

class CampanhaCard extends StatelessWidget {
  const CampanhaCard({super.key, required this.campanha, required this.onTap});

  final CampanhaResumo campanha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imagemUrl = ApiClient.resolveUrl(campanha.imagemUrl);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imagemUrl != null
                  ? Image.network(
                      imagemUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (campanha.categoria != null) _Badge(text: campanha.categoria!),
                      const Spacer(),
                      _Badge(
                        text: _tipoLabel(campanha.tipoCampanha),
                        color: AppColors.accentPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    campanha.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (campanha.metaFinanceira != null) ...[
                    AppProgressBar(progress: campanha.progresso),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.currency(campanha.valorArrecadado),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentPink,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'meta ${Formatters.currency(campanha.metaFinanceira)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${campanha.quantidadeDoadores} doadores',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _tipoLabel(String tipo) => switch (tipo) {
        'financeira' => 'Financeira',
        'material' => 'Material',
        _ => 'Financeira e material',
      };

  Widget _placeholderImage() {
    return Container(
      color: AppColors.bgSecondary,
      alignment: Alignment.center,
      child: const Icon(Icons.volunteer_activism_rounded,
          size: 40, color: AppColors.textSecondary),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.color = AppColors.button});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
