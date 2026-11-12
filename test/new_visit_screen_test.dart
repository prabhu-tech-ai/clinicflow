import 'package:clinicflow/features/visits/new_visit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping Visit Date opens the date picker', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewVisitScreen()));

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
