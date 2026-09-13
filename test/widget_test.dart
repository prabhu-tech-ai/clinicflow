import 'package:flutter_test/flutter_test.dart';

import 'package:clinicflow/main.dart';

void main() {
  testWidgets('clinic navigation flow opens dashboard and patients', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Clinic\nManagement'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.text('Patients').last);
    await tester.pumpAndSettle();
    expect(find.text('Ramesh Kumar'), findsWidgets);
  });
}
