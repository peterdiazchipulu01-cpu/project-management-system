import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ProgressBar extends StatelessWidget {
  final int progress;
  final double height;

  const ProgressBar({super.key, required this.progress, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: progress / 100,
        minHeight: height,
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
      ),
    );
  }
}
