import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MedicalListScreen extends StatelessWidget {
  const MedicalListScreen({super.key});
  static const medicines = [
    ('Paracetamol 500mg', 'Tablet'),
    ('Cetirizine 10mg', 'Tablet'),
    ('Amoxicillin 500mg', 'Capsule'),
    ('ORS', 'Powder'),
    ('Azithromycin 500mg', 'Tablet'),
    ('Vitamin D3 60K', 'Capsule'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Medicines',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search medicines',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...medicines.map(
          (medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Row(
                children: [
                  const Icon(Icons.medication_outlined, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          medicine.$2,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
