import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Card(child: ListTile(leading: Icon(Icons.straighten), title: Text('Measurement units'), subtitle: Text('Height: centimeters  •  Weight: kilograms'))),
    Card(child: ListTile(leading: Icon(Icons.notifications_none), title: Text('Notifications'), subtitle: Text('Notification preferences can be added later.'))),
    Card(child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Appearance'), subtitle: Text('Dark navy and teal theme'))),
  ]);
}
