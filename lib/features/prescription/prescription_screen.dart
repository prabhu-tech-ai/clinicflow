import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Prescription',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ramesh Kumar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Text(
                'P000125  •  05 Sep 2026',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const Divider(height: 26),
              const _MedicineRow('Paracetamol 500mg', '1 - 0 - 1', '5 Days'),
              const _MedicineRow('Cetirizine 10mg', '1 - 0 - 0', '5 Days'),
              const _MedicineRow('ORS', '1 Packet', '3 Days'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('Save & Print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow(this.name, this.dose, this.duration);
  final String name;
  final String dose;
  final String duration;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        const Icon(Icons.medication_outlined, color: AppColors.teal, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$dose  •  $duration',
          style: const TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    ),
  );
}
