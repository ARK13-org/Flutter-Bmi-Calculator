import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../services/api_client.dart';
import '../services/bmi_service.dart';
import '../services/settings_service.dart';
import '../utils/units.dart';
import '../theme/app_theme.dart';
import '../widgets/bmi_chart.dart';

class HistoryScreen extends StatefulWidget {
  final bool isActive;

  const HistoryScreen({
    super.key,
    this.isActive = false,
  });
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BmiRecord> _records = [];
  bool _loading = true;
  String? _error;
  String _unitSystem = 'metric';
  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _load();
    }
  }

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
          [BmiService.instance.history(), SettingsService.instance.get()]);
      _records = values[0] as List<BmiRecord>;
      _unitSystem =
          ((values[1] as Map<String, dynamic>)['unit_system'] ?? 'metric')
              .toString();
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _delete(BmiRecord r) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Delete measurement?'),
                content: const Text('This record will be permanently deleted.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'))
                ]));
    if (confirm != true) return;
    try {
      await BmiService.instance.delete(r.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _edit(BmiRecord record) async {
    final height = TextEditingController(
        text: (_unitSystem == 'imperial'
                ? Units.cmToIn(record.heightCm)
                : record.heightCm)
            .toStringAsFixed(1));
    final weight = TextEditingController(
        text: (_unitSystem == 'imperial'
                ? Units.kgToLb(record.weightKg)
                : record.weightKg)
            .toStringAsFixed(1));
    final note = TextEditingController(text: record.note ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Edit measurement'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: height,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: _unitSystem == 'imperial'
                            ? 'Height (in)'
                            : 'Height (cm)')),
                const SizedBox(height: 10),
                TextField(
                    controller: weight,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: _unitSystem == 'imperial'
                            ? 'Weight (lb)'
                            : 'Weight (kg)')),
                const SizedBox(height: 10),
                TextField(
                    controller: note,
                    maxLength: 1000,
                    decoration: const InputDecoration(labelText: 'Note')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Save'))
              ],
            ));
    if (ok == true) {
      final enteredH = double.tryParse(height.text.trim());
      final enteredW = double.tryParse(weight.text.trim());
      final h = enteredH == null
          ? null
          : (_unitSystem == 'imperial' ? Units.inToCm(enteredH) : enteredH);
      final w = enteredW == null
          ? null
          : (_unitSystem == 'imperial' ? Units.lbToKg(enteredW) : enteredW);
      if (h == null || w == null || h <= 50 || h > 280 || w <= 10 || w > 500) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enter valid height and weight values.')));
        }
      } else {
        try {
          await BmiService.instance.update(record.id,
              heightCm: h,
              weightKg: w,
              note: note.text.trim().isEmpty ? null : note.text.trim());
          await _load();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      }
    }
    height.dispose();
    weight.dispose();
    note.dispose();
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
    if (_records.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'No BMI records yet. Calculate your first BMI from the dashboard.')));
    }
    return RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          BmiChart(records: _records),
          const SizedBox(height: 18),
          const Text('All measurements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._records.map((r) => Card(
                  child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: .15),
                    child: Text(r.bmi.toStringAsFixed(0),
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold))),
                title:
                    Text('BMI ${r.bmi.toStringAsFixed(1)}  •  ${r.category}'),
                subtitle: Text(
                    '${Units.weight(r.weightKg, _unitSystem)}  •  ${Units.height(r.heightCm, _unitSystem)}\n${_date(r.createdAt)}${r.note == null || r.note!.isEmpty ? '' : '\n${r.note}'}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _edit(r);
                      if (v == 'delete') _delete(r);
                    },
                    itemBuilder: (ctx) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete'))
                        ]),
              ))),
        ]));
  }
}
