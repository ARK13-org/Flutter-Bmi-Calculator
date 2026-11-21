import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/api_client.dart';
import '../services/goals_service.dart';
import '../services/settings_service.dart';
import '../utils/units.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<GoalModel> _goals = [];
  Map<String, dynamic>? _progress;
  bool _loading = true;
  String? _error;
  String _unitSystem = 'metric';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        GoalsService.instance.list(),
        GoalsService.instance.progress(),
        SettingsService.instance.get()
      ]);
      _goals = values[0] as List<GoalModel>;
      _progress = values[1] as Map<String, dynamic>;
      _unitSystem =
          ((values[2] as Map<String, dynamic>)['unit_system'] ?? 'metric')
              .toString();
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create() async {
    final title = TextEditingController(text: 'Weight goal');
    final weight = TextEditingController();
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Create a goal'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: title,
                      decoration:
                          const InputDecoration(labelText: 'Goal title')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: weight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: _unitSystem == 'imperial'
                              ? 'Target weight (lb)'
                              : 'Target weight (kg)'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Create'))
                ]));
    if (ok == true) {
      final enteredW = double.tryParse(weight.text.trim());
      final w = enteredW == null
          ? null
          : (_unitSystem == 'imperial' ? Units.lbToKg(enteredW) : enteredW);
      if (title.text.trim().length < 2 || w == null || w <= 10 || w > 500) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Enter a title and target weight between 10 and 500 kg.')));
        }
      } else {
        try {
          await GoalsService.instance
              .create(title: title.text.trim(), targetWeightKg: w);
          await _load();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      }
    }
    title.dispose();
    weight.dispose();
  }

  Future<void> _delete(GoalModel g) async {
    try {
      await GoalsService.instance.delete(g.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _toggle(GoalModel g, bool active) async {
    try {
      await GoalsService.instance.update(g.id, isActive: active);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_error!),
                const SizedBox(height: 12),
                FilledButton(onPressed: _load, child: const Text('Retry'))
              ])));
    }
    final progress = _progress;
    return RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Your weight goals',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Set a target and follow your progress.',
                      style: TextStyle(color: AppTheme.textSecondary))
                ])),
            IconButton.filled(
                onPressed: _create,
                icon: const Icon(Icons.add),
                tooltip: 'Add goal')
          ]),
          const SizedBox(height: 16),
          if (progress?['available'] == true)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Active goal progress',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                              '${Units.weight((progress!['current_weight_kg'] as num).toDouble(), _unitSystem)}  →  ${Units.weight((progress['target_weight_kg'] as num).toDouble(), _unitSystem)}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                              'Remaining: ${Units.weight((progress['remaining_kg'] as num).toDouble(), _unitSystem)}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary)),
                          if (progress['is_target_reached'] == true)
                            const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Target reached!',
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold)))
                        ])))
          else
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        'Add a BMI measurement and an active goal to see your progress.',
                        style: TextStyle(color: AppTheme.textSecondary)))),
          const SizedBox(height: 16),
          if (_goals.isEmpty)
            const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                    'You have no goals yet. Create your first weight goal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary))),
          ..._goals.map((g) => Card(
                  child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: .15),
                    child: const Icon(Icons.flag_outlined,
                        color: AppTheme.primary)),
                title: Text(g.title),
                subtitle: Text(
                    'Target: ${Units.weight(g.targetWeightKg, _unitSystem)}${g.targetDate == null ? '' : '  •  ${g.targetDate!.toLocal().toString().split(' ').first}'}'),
                trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'delete') _delete(g);
                      if (v == 'activate') _toggle(g, true);
                      if (v == 'deactivate') _toggle(g, false);
                    },
                    itemBuilder: (ctx) => [
                          PopupMenuItem(
                              value: g.isActive ? 'deactivate' : 'activate',
                              child: Text(
                                  g.isActive ? 'Deactivate' : 'Set active')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('Delete'))
                        ]),
                isThreeLine: false,
              ))),
        ]));
  }
}
