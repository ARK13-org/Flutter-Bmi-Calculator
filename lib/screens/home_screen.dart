import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/bmi_service.dart';
import '../services/user_service.dart';
import '../services/settings_service.dart';
import '../utils/units.dart';
import '../theme/app_theme.dart';
import '../widgets/bmi_chart.dart';
import '../widgets/bmi_comparison_card.dart';
import '../widgets/bmi_result_card.dart';

class HomeScreen extends StatefulWidget {
  final bool isActive;

  const HomeScreen({
    super.key,
    this.isActive = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _note = TextEditingController();

  List<BmiRecord> _records = [];
  UserModel? _user;
  Map<String, dynamic>? _dashboard;

  bool _loading = true;
  bool _saving = false;

  String? _error;
  String _unitSystem = 'metric';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        BmiService.instance.history(),
        UserService.instance.getProfile(),
        BmiService.instance.dashboard(),
        SettingsService.instance.get(),
      ]);

      if (!mounted) return;

      final records = results[0] as List<BmiRecord>;
      final user = results[1] as UserModel;
      final dashboard = results[2] as Map<String, dynamic>;
      final settings = results[3] as Map<String, dynamic>;

      final newUnitSystem = (settings['unit_system'] ?? 'metric').toString();

      final validUnitSystem =
          newUnitSystem == 'imperial' ? 'imperial' : 'metric';

      final oldUnitSystem = _unitSystem;

      // Convert existing input values if the preferred unit changed.
      if (oldUnitSystem != validUnitSystem) {
        final oldHeight = double.tryParse(_height.text.trim());
        final oldWeight = double.tryParse(_weight.text.trim());

        if (oldHeight != null) {
          _height.text = (validUnitSystem == 'imperial'
                  ? Units.cmToIn(oldHeight)
                  : Units.inToCm(oldHeight))
              .toStringAsFixed(1);
        }

        if (oldWeight != null) {
          _weight.text = (validUnitSystem == 'imperial'
                  ? Units.kgToLb(oldWeight)
                  : Units.lbToKg(oldWeight))
              .toStringAsFixed(1);
        }
      }

      _records = records;
      _user = user;
      _dashboard = dashboard;
      _unitSystem = validUnitSystem;

      // Use the profile height when the input is empty.
      if (_height.text.isEmpty && user.heightCm != null) {
        final height = _unitSystem == 'imperial'
            ? Units.cmToIn(user.heightCm!)
            : user.heightCm!;

        _height.text = height.toStringAsFixed(1);
      }

      // Fall back to the latest measurement's height.
      if (_height.text.isEmpty && records.isNotEmpty) {
        final height = _unitSystem == 'imperial'
            ? Units.cmToIn(records.first.heightCm)
            : records.first.heightCm;

        _height.text = height.toStringAsFixed(1);
      }

      // Use the latest measurement's weight when available.
      if (_weight.text.isEmpty && records.isNotEmpty) {
        final weight = _unitSystem == 'imperial'
            ? Units.kgToLb(records.first.weightKg)
            : records.first.weightKg;

        _weight.text = weight.toStringAsFixed(1);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    final enteredHeight = double.tryParse(_height.text.trim());
    final enteredWeight = double.tryParse(_weight.text.trim());

    if (enteredHeight == null || enteredWeight == null) {
      setState(() {
        _error = 'Enter valid height and weight values.';
      });
      return;
    }

    // Convert values to the units expected by the backend.
    final heightCm =
        _unitSystem == 'imperial' ? Units.inToCm(enteredHeight) : enteredHeight;

    final weightKg =
        _unitSystem == 'imperial' ? Units.lbToKg(enteredWeight) : enteredWeight;

    if (heightCm < 50 || heightCm > 280 || weightKg < 10 || weightKg > 500) {
      setState(() {
        _error = _unitSystem == 'imperial'
            ? 'Enter height between 19.7–110.2 in and weight between 22–1102 lb.'
            : 'Enter height between 50–280 cm and weight between 10–500 kg.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final record = await BmiService.instance.create(
        heightCm: heightCm,
        weightKg: weightKg,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      if (!mounted) return;

      _note.clear();

      // Refresh history, profile and dashboard after saving.
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'BMI ${record.bmi.toStringAsFixed(1)} saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e is ApiException ? e.message : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _records.isEmpty && _user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final latest = _records.isEmpty ? null : _records.first;
    final previous = _records.length < 2 ? null : _records[1];

    final firstName = (_user?.name.trim().isNotEmpty == true)
        ? _user!.name.trim().split(' ').first
        : 'there';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
            'Good to see you, $firstName',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Here is your health overview.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            _errorCard(_error!),
            const SizedBox(height: 12),
          ],
          if (latest != null)
            BmiResultCard(
              record: latest,
              unitSystem: _unitSystem,
            )
          else
            _emptyCard(),
          const SizedBox(height: 12),
          BmiComparisonCard(
            latest: latest,
            previous: previous,
          ),
          const SizedBox(height: 12),
          if (_records.isNotEmpty) ...[
            BmiChart(records: _records),
            const SizedBox(height: 22),
          ],
          const Text(
            'New measurement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Record your height and current weight.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _height,
                          'Height',
                          _unitSystem == 'imperial' ? 'in' : 'cm',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _weight,
                          'Weight',
                          _unitSystem == 'imperial' ? 'lb' : 'kg',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _note,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.calculate_outlined),
                      label: Text(
                        _saving ? 'Saving...' : 'Calculate & save BMI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_dashboard?['total_records'] != null)
            Text(
              'You have ${_dashboard!['total_records']} saved measurements.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'BMI is a screening measure, not a medical diagnosis.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String unit,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
      ),
    );
  }

  Widget _emptyCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No measurements yet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your latest BMI result will appear here after your first calculation.',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Retry',
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
