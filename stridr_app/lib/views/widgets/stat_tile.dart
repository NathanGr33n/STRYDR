import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final double fontSize;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.fontSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.statLabel(),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTheme.statNumber(fontSize: fontSize),
            ),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Text(
                unit!,
                style: AppTheme.statLabel(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
