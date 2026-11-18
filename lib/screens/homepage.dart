import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../models/user_model.dart';
import '../services/mock_bmi_service.dart';
import '../services/mock_user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bmi_result_card.dart';
import '../widgets/bmi_comparison_card.dart';
import '../widgets/bmi_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');

  final _bmiService = MockBmiService.instance;
  final _userService = MockUserService.instance;

  List<BmiRecord> _records = [];
  UserModel? _user;

  bool _loading = false;
  String? _error;

  BmiRecord? get _latest => _records.isEmpty ? null : _records.first;

  BmiRecord? get _previous => _records.length < 2 ? null : _records[1];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final results = await Future.wait([
      _bmiService.getHistory(),
      _userService.getProfile(),
    ]);

    if (!mounted) return;

    setState(() {
      _records = results[0] as List<BmiRecord>;
      _user = results[1] as UserModel;
    });
  }

  Future<void> _calculate() async {
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (height == null ||
        weight == null ||
        height < 50 ||
        height > 250 ||
        weight < 10 ||
        weight > 500) {
      setState(() {
        _error = 'Enter a valid height (50–250 cm) and weight (10–500 kg).';
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    await _bmiService.addRecord(heightCm: height, weightKg: weight);

    await _loadDashboard();

    if (mounted) {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your new BMI measurement has been saved.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _user?.name.split(' ').first ?? 'there';

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          // Welcome header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good to see you, $userName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Here is your health overview.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primary,
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // BMI overview
          _sectionTitle('BMI overview', 'Your latest measurement'),

          const SizedBox(height: 12),

          if (_latest != null)
            BmiResultCard(record: _latest!)
          else
            _emptyCard(
              'No BMI measurements yet.',
              'Calculate your first BMI to see your results here.',
            ),

          const SizedBox(height: 22),

          // Statistics
          _sectionTitle('Your statistics', 'A quick look at your progress'),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Current weight',
                  value: _latest == null
                      ? '--'
                      : _latest!.weightKg.toStringAsFixed(1),
                  unit: 'kg',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Measurements',
                  value: '${_records.length}',
                  unit: 'records',
                  icon: Icons.assignment_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _buildBmiChangeCard(),

          const SizedBox(height: 24),

          // BMI chart
          _sectionTitle('BMI progress', 'Your recent measurements'),

          const SizedBox(height: 12),

          if (_records.isNotEmpty)
            BmiChart(records: _records)
          else
            _emptyCard(
              'No progress to display',
              'Your BMI chart will appear after your first measurement.',
            ),

          const SizedBox(height: 24),

          // Comparison
          _sectionTitle('Previous comparison', 'Compare your latest results'),

          const SizedBox(height: 12),

          BmiComparisonCard(latest: _latest, previous: _previous),

          const SizedBox(height: 24),

          // Calculator
          _sectionTitle('New measurement', 'Calculate your BMI'),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _measurementField(
                          controller: _heightController,
                          label: 'Height',
                          unit: 'cm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _measurementField(
                          controller: _weightController,
                          label: 'Weight',
                          unit: 'kg',
                        ),
                      ),
                    ],
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _calculate,
                      icon: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.calculate_outlined),
                      label: Text(
                        _loading ? 'Calculating...' : 'Calculate BMI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // BMI categories
          _sectionTitle('BMI categories', 'General adult reference ranges'),

          const SizedBox(height: 12),

          const _CategoryTile(
            title: 'Underweight',
            range: 'Below 18.5',
            color: Colors.lightBlueAccent,
          ),
          const _CategoryTile(
            title: 'Normal range',
            range: '18.5 – 24.9',
            color: AppTheme.primary,
          ),
          const _CategoryTile(
            title: 'Overweight',
            range: '25.0 – 29.9',
            color: Colors.orangeAccent,
          ),
          const _CategoryTile(
            title: 'Obesity',
            range: '30.0 or above',
            color: Colors.redAccent,
          ),

          const SizedBox(height: 12),

          const Text(
            'BMI is a screening measure, not a diagnosis. It does not '
            'directly measure body fat or distinguish muscle from fat.',
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiChangeCard() {
    if (_latest == null || _previous == null) {
      return const _StatCard(
        title: 'BMI change',
        value: '--',
        unit: 'Need 2 measurements',
        icon: Icons.trending_up,
      );
    }

    final difference = _latest!.bmi - _previous!.bmi;
    final isUnchanged = difference.abs() < 0.05;

    return _StatCard(
      title: 'BMI change',
      value: '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}',
      unit: isUnchanged ? 'No significant change' : 'Since last measurement',
      icon: difference < 0 ? Icons.trending_down : Icons.trending_up,
    );
  }

  Widget _measurementField({
    required TextEditingController controller,
    required String label,
    required String unit,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: unit),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _emptyCard(String title, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.insights_outlined,
              size: 32,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String range;
  final Color color;

  const _CategoryTile({
    required this.title,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 9,
          height: 35,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(range, style: const TextStyle(color: Colors.white60)),
      ),
    );
  }
}
