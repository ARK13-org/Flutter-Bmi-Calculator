import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChanged;
  const SettingsScreen({super.key, required this.onThemeChanged});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _units = 'metric';
  String _theme = 'dark';
  bool _notifications = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await SettingsService.instance.get();
      _units = (data['unit_system'] ?? 'metric').toString();
      _theme = (data['theme'] ?? 'dark').toString();
      _notifications = data['notifications_enabled'] == true;
      widget.onThemeChanged(_theme);
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save(
      {String? units, String? theme, bool? notifications}) async {
    setState(() => _saving = true);
    try {
      final data = await SettingsService.instance.update(
          unitSystem: units, theme: theme, notificationsEnabled: notifications);
      setState(() {
        _units = (data['unit_system'] ?? _units).toString();
        _theme = (data['theme'] ?? _theme).toString();
        _notifications = data['notifications_enabled'] == true;
        _error = null;
      });
      widget.onThemeChanged(_theme);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Settings saved.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e is ApiException ? e.message : e.toString());
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.straighten, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Text('Measurement units',
                          style: TextStyle(fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                        initialValue: _units,
                        decoration:
                            const InputDecoration(labelText: 'Unit system'),
                        items: const [
                          DropdownMenuItem(
                              value: 'metric', child: Text('Metric (cm / kg)')),
                          DropdownMenuItem(
                              value: 'imperial',
                              child: Text('Imperial (in / lb)'))
                        ],
                        onChanged: _saving
                            ? null
                            : (v) => v == null ? null : _save(units: v)),
                  ]))),
      const SizedBox(height: 12),
      Card(
          child: SwitchListTile(
              value: _notifications,
              onChanged: _saving ? null : (v) => _save(notifications: v),
              secondary:
                  const Icon(Icons.notifications_none, color: AppTheme.primary),
              title: const Text('Notifications'),
              subtitle: const Text('Enable app notification preferences'))),
      const SizedBox(height: 12),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.palette_outlined, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Text('Appearance',
                          style: TextStyle(fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                        initialValue: _theme,
                        decoration: const InputDecoration(labelText: 'Theme'),
                        items: const [
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                          DropdownMenuItem(
                              value: 'light', child: Text('Light')),
                          DropdownMenuItem(
                              value: 'system', child: Text('System default'))
                        ],
                        onChanged: _saving
                            ? null
                            : (v) => v == null ? null : _save(theme: v)),
                  ]))),
      if (_saving)
        const Padding(
            padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
      if (_error != null)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(_error!, style: const TextStyle(color: Colors.redAccent))),
      const SizedBox(height: 16),
      const Text(
          'Your preferences are saved to your account and shared across devices.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
