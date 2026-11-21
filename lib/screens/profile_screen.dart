import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';
import '../services/settings_service.dart';
import '../utils/units.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<String>? onNameChanged;

  const ProfileScreen({
    super.key,
    this.onNameChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _unitSystem = 'metric';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final values = await Future.wait(
          [UserService.instance.getProfile(), SettingsService.instance.get()]);
      _user = values[0] as UserModel;
      widget.onNameChanged?.call(_user!.name);
      _unitSystem =
          ((values[1] as Map<String, dynamic>)['unit_system'] ?? 'metric')
              .toString();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _edit() async {
    if (_user == null) return;
    final name = TextEditingController(text: _user!.name);
    final age = TextEditingController(text: _user!.age?.toString() ?? '');
    final height = TextEditingController(
        text: _user!.heightCm == null
            ? ''
            : (_unitSystem == 'imperial'
                    ? Units.cmToIn(_user!.heightCm!)
                    : _user!.heightCm!)
                .toStringAsFixed(1));
    final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Edit profile'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: name,
                      decoration:
                          const InputDecoration(labelText: 'Full name')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: height,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: _unitSystem == 'imperial'
                              ? 'Height (in)'
                              : 'Height (cm)'))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save'))
                ]));
    if (saved == true) {
      final a = age.text.trim().isEmpty ? null : int.tryParse(age.text.trim());
      final enteredH = height.text.trim().isEmpty
          ? null
          : double.tryParse(height.text.trim());
      final h = enteredH == null
          ? null
          : (_unitSystem == 'imperial' ? Units.inToCm(enteredH) : enteredH);
      if (name.text.trim().length < 2 ||
          (age.text.trim().isNotEmpty && (a == null || a < 13 || a > 120)) ||
          (height.text.trim().isNotEmpty &&
              (h == null || h <= 50 || h > 280))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Please check the profile values. Age must be 13–120 and height 50–280 cm.')));
        }
      } else {
        setState(() => _saving = true);
        try {
          final updatedUser = await UserService.instance.updateProfile(
            name: name.text.trim(),
            age: a,
            heightCm: h,
          );

          if (mounted) {
            setState(() {
              _user = updatedUser;
            });

            widget.onNameChanged?.call(updatedUser.name);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
        if (mounted) setState(() => _saving = false);
      }
    }
    name.dispose();
    age.dispose();
    height.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_user == null) {
      return Center(child: Text(_error ?? 'Profile unavailable'));
    }
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 16),
      const CircleAvatar(
          radius: 48,
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.person, size: 54, color: Color(0xFF101820))),
      const SizedBox(height: 14),
      Center(
          child: Text(_user!.name,
              style:
                  const TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
      Center(
          child: Text(_user!.email,
              style: const TextStyle(color: AppTheme.textSecondary))),
      const SizedBox(height: 26),
      _info('Age', _user!.age == null ? 'Not set' : '${_user!.age} years',
          Icons.cake_outlined),
      _info(
          'Height',
          _user!.heightCm == null
              ? 'Not set'
              : Units.height(_user!.heightCm!, _unitSystem),
          Icons.height),
      _info('Account ID', '${_user!.id}', Icons.badge_outlined),
      const SizedBox(height: 18),
      FilledButton.icon(
          onPressed: _saving ? null : _edit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(_saving ? 'Saving...' : 'Edit profile')),
      if (_error != null)
        Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                Text(_error!, style: const TextStyle(color: Colors.redAccent))),
    ]);
  }

  Widget _info(String label, String value, IconData icon) => Card(
      child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          subtitle: Text(value, style: const TextStyle(fontSize: 16))));
}
