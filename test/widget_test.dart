import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:clinicflow/main.dart';

void main() {
  testWidgets('blank login opens the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Clinic\nManagement'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.text('Patients').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Patients'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
