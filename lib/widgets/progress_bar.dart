import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.progress, this.height = 8});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: height,
        backgroundColor: AppColors.bgPrimary,
        valueColor: const AlwaysStoppedAnimation(AppColors.accentPurple),
      ),
    );
  }
}
