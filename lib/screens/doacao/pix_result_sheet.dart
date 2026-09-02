import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../models/pix_response.dart';

class PixResultSheet extends StatefulWidget {
  const PixResultSheet({super.key, this.pix, this.error});

  final PixResponse? pix;
  final String? error;

  @override
  State<PixResultSheet> createState() => _PixResultSheetState();
}

class _PixResultSheetState extends State<PixResultSheet> {
  bool _copiado = false;

  Future<void> _copiar(String codigo) async {
    await Clipboard.setData(ClipboardData(text: codigo));
    setState(() => _copiado = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pix = widget.pix;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppColors.logoGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Doação registrada!',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text('Obrigado pela sua contribuição.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            if (pix != null && pix.qrCodeBase64.isNotEmpty) ...[
              const Text('Pague via PIX',
                  style: TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(pix.qrCodeBase64),
                  width: 200,
                  height: 200,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Icon(Icons.qr_code_2_rounded, size: 80, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  pix.pixCopiaECola,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copiar(pix.pixCopiaECola),
                  icon: Icon(_copiado ? Icons.check : Icons.copy_rounded,
                      color: _copiado ? AppColors.success : AppColors.accentPurple),
                  label: Text(
                    _copiado ? 'Copiado!' : 'Copiar código PIX',
                    style: TextStyle(
                        color: _copiado ? AppColors.success : AppColors.accentPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: _copiado ? AppColors.success : AppColors.accentPurple),
                  ),
                ),
              ),
            ] else if (widget.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.error!,
                          style: const TextStyle(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
