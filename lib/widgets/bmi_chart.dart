import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../theme/app_theme.dart';

class BmiChart extends StatelessWidget {
  final List<BmiRecord> records;

  const BmiChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final items = records.reversed.take(7).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = items.map((record) => record.bmi).toList();

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final difference = maxValue - minValue;
    final chartMin = minValue - (difference == 0 ? 2 : difference * 0.25);
    final chartMax = maxValue + (difference == 0 ? 2 : difference * 0.25);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BMI history',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.show_chart, color: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${items.length} recent measurements',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              width: double.infinity,
              child: CustomPaint(
                painter: _BmiChartPainter(
                  values: values,
                  minValue: chartMin,
                  maxValue: chartMax,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(items.first.createdAt),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _formatDate(items.last.createdAt),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((record) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    record.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _BmiChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;

  _BmiChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const horizontalPadding = 8.0;
    const topPadding = 20.0;
    const bottomPadding = 20.0;

    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;

      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : horizontalPadding + (chartWidth / (values.length - 1)) * i;

      final normalized = (values[i] - minValue) / (maxValue - minValue);

      final y = topPadding + chartHeight * (1 - normalized);

      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final areaPath = Path()
        ..moveTo(points.first.dx, size.height - bottomPadding);

      for (final point in points) {
        areaPath.lineTo(point.dx, point.dy);
      }

      areaPath
        ..lineTo(points.last.dx, size.height - bottomPadding)
        ..close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withValues(alpha: 0.25),
            AppTheme.primary.withValues(alpha: 0.01),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, areaPaint);
    }

    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()..color = AppTheme.primary;

    final borderPaint = Paint()..color = AppTheme.surface;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 6, borderPaint);
      canvas.drawCircle(points[i], 4, pointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toStringAsFixed(1),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textX = (points[i].dx - textPainter.width / 2).clamp(
        0.0,
        size.width - textPainter.width,
      );

      textPainter.paint(canvas, Offset(textX, points[i].dy - 19));
    }
  }

  @override
  bool shouldRepaint(covariant _BmiChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
