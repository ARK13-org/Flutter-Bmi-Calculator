import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'widgets/app_drawer.dart';
import 'theme/app_theme.dart';

void main() => runApp(const BmiApp());

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Tracker',
      theme: AppTheme.dark,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _pages = const [
    HomePage(),
    ProfileScreen(),
    HistoryScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  final _titles = const ['BMI Tracker', 'My Profile', 'BMI History', 'Settings', 'About'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
