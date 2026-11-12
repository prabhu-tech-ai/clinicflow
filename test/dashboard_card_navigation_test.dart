import 'package:clinicflow/features/dashboard/dashboard_metric_screen.dart';
import 'package:clinicflow/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard metric cards open their matching detail screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.pump(const Duration(milliseconds: 350));

    const metrics = {
      "Today's Patients": DashboardMetric.todayPatients,
      'New Patients': DashboardMetric.newPatients,
      'Follow-ups': DashboardMetric.followUps,
      'Doctors': DashboardMetric.doctors,
    };
    for (final entry in metrics.entries) {
      await tester.ensureVisible(find.text(entry.key).first);
      await tester.tap(find.text(entry.key).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(DashboardMetricScreen), findsOneWidget);
      expect(
        tester
            .widget<DashboardMetricScreen>(find.byType(DashboardMetricScreen))
            .metric,
        entry.value,
      );
      Navigator.of(tester.element(find.byType(DashboardMetricScreen))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
