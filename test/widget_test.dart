import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculater/main.dart';

void main() {
  testWidgets('BMI Tracker app loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BmiApp());

    expect(find.text('BMI Tracker'), findsOneWidget);
    expect(find.text('Calculate your BMI'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });
}
