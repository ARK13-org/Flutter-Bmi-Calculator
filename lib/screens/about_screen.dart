import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.monitor_weight, size: 42, color: Colors.white),
          ),
          SizedBox(height: 18),
          Text(
            'BMI Tracker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'A simple app to calculate BMI, review previous measurements, and follow changes over time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          SizedBox(height: 14),
          Text(
            'Version 1.0.0  •  Demo project',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
