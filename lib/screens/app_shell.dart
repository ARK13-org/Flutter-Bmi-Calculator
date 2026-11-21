import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  final Future<void> Function() onSignOut;
  final ValueChanged<String> onThemeChanged;
  const AppShell(
      {super.key, required this.onSignOut, required this.onThemeChanged});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  String _name = 'BMI Tracker';
  List<Widget> get _pages => [
        const HomeScreen(),
        HistoryScreen(isActive: _index == 1),
        const GoalsScreen(),
        const ProfileScreen(),
        SettingsScreen(onThemeChanged: widget.onThemeChanged),
        const AboutScreen(),
      ];
  final _titles = const [
    'Dashboard',
    'BMI History',
    'Weight Goals',
    'My Profile',
    'Settings',
    'About'
  ];

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final user = await AuthService.instance.me();
      if (mounted) setState(() => _name = user.name);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: true),
      drawer: NavigationDrawer(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          Navigator.pop(context);
        },
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 16, 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.monitor_weight_outlined,
                            color: Color(0xFF101820), size: 30)),
                    const SizedBox(height: 12),
                    Text(_name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Your personal health companion',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ])),
          const Divider(),
          const NavigationDrawerDestination(
              icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.history), label: Text('BMI History')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.flag_outlined), label: Text('Weight Goals')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.person_outline), label: Text('My Profile')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.settings_outlined), label: Text('Settings')),
          const NavigationDrawerDestination(
              icon: Icon(Icons.info_outline), label: Text('About')),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                Navigator.pop(context);
                await widget.onSignOut();
              }),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
