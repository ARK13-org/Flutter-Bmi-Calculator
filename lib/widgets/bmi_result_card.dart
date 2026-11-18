import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../theme/app_theme.dart';

class BmiResultCard extends StatelessWidget {
  final BmiRecord record;
  const BmiResultCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your latest BMI',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 8),
                  child: Text('BMI', style: TextStyle(color: Colors.white60)),
                ),
              ],
            ),
            Text(
              record.category,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${record.weightKg.toStringAsFixed(1)} kg  •  ${record.heightCm.toStringAsFixed(0)} cm',
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
