import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../theme/app_theme.dart';
import '../utils/units.dart';

class BmiResultCard extends StatelessWidget {
  final BmiRecord record;
  final String unitSystem;
  const BmiResultCard(
      {super.key, required this.record, this.unitSystem = 'metric'});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your latest BMI',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(record.bmi.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.bold)),
              const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 8),
                  child: Text('BMI',
                      style: TextStyle(color: AppTheme.textSecondary)))
            ]),
            Text(record.category,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(
                '${Units.weight(record.weightKg, unitSystem)}  •  ${Units.height(record.heightCm, unitSystem)}',
                style: const TextStyle(color: AppTheme.textSecondary)),
          ])));
}
