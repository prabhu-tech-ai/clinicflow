import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/clinic_inputs.dart';
import '../../repositories/clinic_repository.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  bool _saving = false;

  Future<void> _savePrescription() async {
    setState(() => _saving = true);
    try {
      var patient = await clinicRepository.patients.findByName('Ramesh Kumar');
      patient ??= await clinicRepository.savePatient(const PatientInput(fullName: 'Ramesh Kumar'));
      final visits = await clinicRepository.visits.watchForPatient(patient.id).first;
      final visit = visits.isNotEmpty ? visits.first : await clinicRepository.saveVisit(VisitInput(patientId: patient.id, visitType: 'New Visit', visitDate: DateTime.now()));
      final itemInputs = <PrescriptionItemInput>[];
      for (final item in const [('Paracetamol 500mg', '1 - 0 - 1', '5 Days'), ('Cetirizine 10mg', '1 - 0 - 0', '5 Days'), ('ORS', '1 Packet', '3 Days')]) {
        final medicine = await clinicRepository.medicines.findByName(item.$1) ?? await clinicRepository.saveMedicine(MedicineInput(name: item.$1));
        itemInputs.add(PrescriptionItemInput(medicineId: medicine.id, dosage: item.$2, frequency: item.$2, duration: item.$3));
      }
      await clinicRepository.savePrescription(PrescriptionInput(visitId: visit.id, patientId: patient.id, items: itemInputs));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription saved successfully')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save prescription')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                      onPressed: _saving ? null : _savePrescription,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _savePrescription,
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
