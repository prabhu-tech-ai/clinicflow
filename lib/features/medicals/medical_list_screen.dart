import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/clinic_inputs.dart';
import '../../repositories/clinic_repository.dart';
import '../../database/database.dart';

class MedicalListScreen extends StatelessWidget {
  const MedicalListScreen({super.key});

  Future<void> _addMedicine(BuildContext context) async {
    final nameController = TextEditingController();
    final formController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add medicine'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: formController,
                decoration: const InputDecoration(labelText: 'Form'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await clinicRepository.saveMedicine(
                MedicineInput(name: nameController.text, form: formController.text),
              );
              if (context.mounted) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    formController.dispose();
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Medicines',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [IconButton(onPressed: () => _addMedicine(context), icon: const Icon(Icons.add))],
    ),
    body: StreamBuilder<List<Medicine>>(
      stream: clinicRepository.medicines.watchMedicines(),
      builder: (context, snapshot) {
        final medicines = snapshot.data ?? const <Medicine>[];
        return ListView(
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
        if (snapshot.connectionState == ConnectionState.waiting)
          const Center(child: CircularProgressIndicator())
        else if (medicines.isEmpty)
          const AppCard(child: Text('No medicines added yet'))
        else ...medicines.map(
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
                          medicine.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${medicine.form ?? 'Medicine'}${medicine.strength == null ? '' : '  ${medicine.strength}'}',
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
        );
      },
    ),
  );
}
