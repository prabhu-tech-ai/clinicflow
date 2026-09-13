import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'patient_profile_screen.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});
  static const patients = [
    ('Ramesh Kumar', 'P000125', '9876543210', '05 Sep 2026'),
    ('Priya Sharma', 'P000126', '9123456780', '04 Sep 2026'),
    ('Amit Singh', 'P000127', '9988776655', '04 Sep 2026'),
    ('Neha Patel', 'P000128', '9033445566', '03 Sep 2026'),
    ('Suresh Rao', 'P000129', '9087654321', '02 Sep 2026'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Patients',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientProfileScreen(isNew: true),
                ),
              ),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by name, mobile or ID',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...patients.map(
          (patient) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: InkWell(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PatientProfileScreen(
                              patientName: patient.$1,
                              patientId: patient.$2,
                            ),
                      ),
                    ),
                child: Row(
                  children: [
                    InitialAvatar(patient.$1[0]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${patient.$2}  |  ${patient.$3}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      patient.$4,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
