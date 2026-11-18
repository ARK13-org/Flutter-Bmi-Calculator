import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../services/mock_bmi_service.dart';
import '../widgets/bmi_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = MockBmiService.instance;
  List<BmiRecord> _records = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final records = await _service.getHistory();
    if (mounted) setState(() { _records = records; _loading = false; });
  }

  Future<void> _delete(BmiRecord record) async {
    await _service.deleteRecord(record.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_records.isEmpty) return const Center(child: Text('No BMI records yet. Calculate your first BMI.'));
    return ListView(padding: const EdgeInsets.all(16), children: [
      BmiChart(records: _records),
      const SizedBox(height: 12),
      const Text('All measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ..._records.map((record) => Card(child: ListTile(
        title: Text('BMI ${record.bmi.toStringAsFixed(1)}  •  ${record.category}'),
        subtitle: Text('${record.weightKg.toStringAsFixed(1)} kg  •  ${record.heightCm.toStringAsFixed(0)} cm\n${_date(record.createdAt)}'),
        isThreeLine: true,
        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(record)),
      ))),
    ]);
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
