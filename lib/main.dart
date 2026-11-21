import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/app_shell.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BmiApp());
}

class BmiApp extends StatefulWidget {
  const BmiApp({super.key});
  @override
  State<BmiApp> createState() => _BmiAppState();
}

class _BmiAppState extends State<BmiApp> {
  bool _checking = true;
  bool _authenticated = false;
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await ApiClient.instance.readToken();
      if (token != null) {
        await AuthService.instance.me();
        _authenticated = true;
      }
    } catch (_) {
      await ApiClient.instance.clearToken();
    }
    if (mounted) setState(() => _checking = false);
  }

  void _onAuthenticated() => setState(() => _authenticated = true);
  Future<void> _onSignOut() async {
    await ApiClient.instance.clearToken();
    if (mounted) setState(() => _authenticated = false);
  }

  void _setTheme(String value) {
    setState(() => _themeMode = switch (value) {
          'light' => ThemeMode.light,
          'system' => ThemeMode.system,
          _ => ThemeMode.dark,
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _checking
          ? const _StartupScreen()
          : _authenticated
              ? AppShell(onSignOut: _onSignOut, onThemeChanged: _setTheme)
              : AuthScreen(onAuthenticated: _onAuthenticated),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

// run : flutter run -d chrome
