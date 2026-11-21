import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
                radius: 38,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.monitor_weight_outlined,
                    size: 42, color: Color(0xFF101820))),
            SizedBox(height: 18),
            Text('BMI Tracker',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
                'Calculate BMI, review previous measurements, compare changes, and follow your weight goals over time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
            SizedBox(height: 14),
            Text('Version 1.1.0  •  FastAPI connected',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))
          ])));
}
