import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../theme/app_theme.dart';

class BmiComparisonCard extends StatelessWidget {
  final BmiRecord? latest;
  final BmiRecord? previous;
  const BmiComparisonCard(
      {super.key, required this.latest, required this.previous});
  @override
  Widget build(BuildContext context) {
    if (latest == null || previous == null) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                  'Add another BMI measurement to compare your results.',
                  style: TextStyle(color: AppTheme.textSecondary))));
    }
    final change = latest!.bmi - previous!.bmi;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Compared with your previous result',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _value('Previous', previous!.bmi)),
                Expanded(child: _value('Latest', latest!.bmi)),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Change',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      Text(
                          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                          style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: change <= 0
                                  ? AppTheme.primary
                                  : Colors.orangeAccent))
                    ]))
              ]),
              const SizedBox(height: 10),
              const Text(
                  'A BMI change is a trend, not a diagnosis or a complete measure of health.',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ])));
  }

  Widget _value(String label, double value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(value.toStringAsFixed(1),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold))
      ]);
}
