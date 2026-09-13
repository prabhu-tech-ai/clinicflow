import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NewVisitScreen extends StatelessWidget {
  const NewVisitScreen({super.key, this.patientName = 'Ramesh Kumar'});
  final String patientName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'New Visit',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Patient',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          value: patientName,
          items:
              [patientName, 'Priya Sharma']
                  .map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)),
                  )
                  .toList(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 18),
        const Text(
          'Visit Type',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            ChoiceChip(
              label: const Text('New Visit'),
              selected: true,
              onSelected: (_) {},
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('Follow-up'),
              selected: false,
              onSelected: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        const AppTextField(label: 'Doctor', hint: 'Select doctor'),
        const SizedBox(height: 18),
        const AppTextField(label: 'Visit Date', hint: '05 Sep 2026'),
        const SizedBox(height: 18),
        const AppTextField(
          label: 'Symptoms',
          hint: 'Fever, headache, body pain',
        ),
        const SizedBox(height: 18),
        const AppTextField(label: 'Notes', hint: 'Add notes'),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Save Visit',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
