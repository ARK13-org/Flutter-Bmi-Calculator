import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/mock_user_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await MockUserService.instance.getProfile();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _edit() async {
    if (_user == null) return;
    final name = TextEditingController(text: _user!.name);
    final email = TextEditingController(text: _user!.email);
    final age = TextEditingController(text: _user!.age.toString());
    final height = TextEditingController(
      text: _user!.heightCm.toStringAsFixed(0),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true) {
      final parsedAge = int.tryParse(age.text);
      final parsedHeight = double.tryParse(height.text);
      if (name.text.trim().isNotEmpty &&
          email.text.contains('@') &&
          parsedAge != null &&
          parsedAge > 0 &&
          parsedHeight != null &&
          parsedHeight > 0) {
        await MockUserService.instance.updateProfile(
          name: name.text.trim(),
          email: email.text.trim(),
          age: parsedAge,
          heightCm: parsedHeight,
        );
        await _load();
      }
    }
    name.dispose();
    email.dispose();
    age.dispose();
    height.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 18),
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.person, size: 55, color: Colors.white),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            _user!.name,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            _user!.email,
            style: const TextStyle(color: Colors.white60),
          ),
        ),
        const SizedBox(height: 28),
        _info('Age', '${_user!.age} years', Icons.cake_outlined),
        _info(
          'Height',
          '${_user!.heightCm.toStringAsFixed(0)} cm',
          Icons.height,
        ),
        _info('User ID', _user!.id, Icons.badge_outlined),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit profile'),
        ),
      ],
    );
  }

  Widget _info(String label, String value, IconData icon) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    ),
  );
}
