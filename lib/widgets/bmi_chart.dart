import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../theme/app_theme.dart';

class BmiChart extends StatelessWidget {
  final List<BmiRecord> records;
  const BmiChart({super.key, required this.records});
  @override
  Widget build(BuildContext context) {
    final values = records.reversed.take(8).map((e) => e.bmi).toList();
    if (values.length < 2) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('Add more measurements to see your BMI trend.')));
    }
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('BMI trend',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 18),
              SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CustomPaint(painter: _TrendPainter(values))),
              const SizedBox(height: 8),
              const Text('Showing your most recent measurements',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ])));
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  _TrendPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final minV = (values.reduce((a, b) => a < b ? a : b) - 1).floorToDouble();
    final maxV = (values.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i * size.width / (values.length - 1);
      final y = size.height -
          ((values[i] - minV) / (maxV - minV)) * (size.height - 22) -
          8;
      points.add(Offset(x, y));
    }
    final grid = Paint()
      ..color = AppTheme.border.withValues(alpha: .7)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = AppTheme.primary;
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, dot);
      final tp = TextPainter(
          text: TextSpan(
              text: values[i].toStringAsFixed(1),
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(
          canvas,
          Offset(
              (points[i].dx - tp.width / 2).clamp(0.0, size.width - tp.width),
              (points[i].dy - 19).clamp(0.0, size.height - tp.height)));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values;
}
