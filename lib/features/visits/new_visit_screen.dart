import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/clinic_inputs.dart';
import '../../repositories/clinic_repository.dart';

class NewVisitScreen extends StatefulWidget {
  const NewVisitScreen({super.key, this.patientName = 'Ramesh Kumar'});
  final String patientName;

  @override
  State<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  final _doctorController = TextEditingController();
  final _dateController = TextEditingController(text: '05 Sep 2026');
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  String _visitType = 'New Visit';
  bool _saving = false;

  @override
  void dispose() {
    _doctorController.dispose();
    _dateController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVisit() async {
    setState(() => _saving = true);
    try {
      var patient = await clinicRepository.patients.findByName(widget.patientName);
      patient ??= await clinicRepository.savePatient(PatientInput(fullName: widget.patientName));
      final visit = await clinicRepository.saveVisit(VisitInput(patientId: patient.id, visitType: _visitType, visitDate: DateTime.now(), symptoms: _symptomsController.text, notes: _notesController.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit saved successfully')));
      Navigator.pop(context, visit.id);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save visit')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
            value: widget.patientName,
            items:
              [widget.patientName, 'Priya Sharma']
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
              selected: _visitType == 'New Visit',
              onSelected: (_) => setState(() => _visitType = 'New Visit'),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('Follow-up'),
              selected: _visitType == 'Follow-up',
              onSelected: (_) => setState(() => _visitType = 'Follow-up'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppTextField(label: 'Doctor', hint: 'Select doctor', controller: _doctorController),
        const SizedBox(height: 18),
        AppTextField(label: 'Visit Date', hint: '05 Sep 2026', controller: _dateController),
        const SizedBox(height: 18),
        AppTextField(
          label: 'Symptoms',
          hint: 'Fever, headache, body pain',
          controller: _symptomsController,
        ),
        const SizedBox(height: 18),
        AppTextField(label: 'Notes', hint: 'Add notes', controller: _notesController),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Save Visit',
          onPressed: _saving ? null : _saveVisit,
        ),
      ],
    ),
  );
}
