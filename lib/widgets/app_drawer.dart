import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _items = [
    (Icons.calculate_outlined, 'BMI Calculator'),
    (Icons.person_outline, 'My Profile'),
    (Icons.history, 'BMI History'),
    (Icons.settings_outlined, 'Settings'),
    (Icons.info_outline, 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: AppTheme.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.surface,
                child: Icon(
                  Icons.monitor_weight,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'BMI Tracker',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Your personal health companion',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white24),
        for (var i = 0; i < _items.length; i++)
          NavigationDrawerDestination(
            icon: Icon(_items[i].$1),
            label: Text(_items[i].$2),
          ),
      ],
    );
  }
}
