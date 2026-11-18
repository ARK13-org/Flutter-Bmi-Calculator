import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../theme/app_theme.dart';

class BmiComparisonCard extends StatelessWidget {
  final BmiRecord? latest;
  final BmiRecord? previous;
  const BmiComparisonCard({
    super.key,
    required this.latest,
    required this.previous,
  });

  @override
  Widget build(BuildContext context) {
    if (latest == null || previous == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'Add another BMI measurement to see your comparison.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    final difference = latest!.bmi - previous!.bmi;
    final improved = difference < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compared with your previous result',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _value('Previous', previous!.bmi)),
                Expanded(child: _value('Latest', latest!.bmi)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      Text(
                        '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: difference == 0
                              ? Colors.white
                              : (improved
                                    ? AppTheme.primary
                                    : Colors.orangeAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'A BMI change is a measurement trend, not a diagnosis or a complete measure of health.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _value(String label, double value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      Text(
        value.toStringAsFixed(1),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
