import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/clinic_inputs.dart';
import '../../repositories/clinic_repository.dart';
import '../../database/database.dart';
import '../visits/new_visit_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({
    super.key,
    this.patientName = 'Ramesh Kumar',
    this.patientId = 'P000125',
    this.isNew = false,
  });
  final String patientName;
  final String patientId;
  final bool isNew;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dateController = TextEditingController();
  Patient? _patient;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNew) _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await clinicRepository.patients.findByCode(widget.patientId);
    if (!mounted || patient == null) return;
    setState(() {
      _patient = patient;
      _nameController.text = patient.fullName;
      _mobileController.text = patient.mobile ?? '';
      _dateController.text = patient.dateOfBirth == null
          ? ''
          : _formatDate(patient.dateOfBirth!);
    });
  }

  void _startEditing() => setState(() => _editing = true);

  Future<void> _selectDateOfBirth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _parseDate(_dateController.text) ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate == null || !mounted) return;
    _dateController.text = _formatDate(selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      final savedPatient = await clinicRepository.savePatient(
        PatientInput(
          fullName: name,
          mobile: _mobileController.text.trim(),
          dateOfBirth: _parseDate(_dateController.text),
        ),
        id: _patient?.id,
      );
      if (!mounted) return;
      _patient = savedPatient;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient saved successfully')));
      if (widget.isNew) {
        Navigator.pop(context);
      } else {
        setState(() => _editing = false);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save patient')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.isNew ? 'New Patient' : 'Patient Profile'),
      actions: [
        if (!widget.isNew)
          IconButton(
            onPressed: _editing ? null : _startEditing,
            icon: const Icon(Icons.edit_outlined),
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Row(
            children: [
              InitialAvatar(
                (widget.isNew ? 'N' : (_patient?.fullName ?? widget.patientName)[0]).toUpperCase(),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isNew ? 'New patient' : (_patient?.fullName ?? widget.patientName),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    widget.isNew
                        ? 'Complete patient details'
                        : '${widget.patientId}  •  Male, 31 Y',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (widget.isNew || _editing) ...[
          AppTextField(label: 'Full Name', hint: 'Enter patient name', controller: _nameController),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Mobile Number',
            hint: 'Enter mobile number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Date of Birth',
            hint: 'DD/MM/YYYY',
            controller: _dateController,
            readOnly: true,
            onTap: _selectDateOfBirth,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save Patient', onPressed: _saving ? null : _savePatient),
        ] else ...[
          const SectionTitle('Patient Details'),
          AppCard(
            child: Column(
              children: [
                _DetailRow('Date of Birth', _patient?.dateOfBirth == null ? 'Not provided' : _formatDate(_patient!.dateOfBirth!)),
                _DetailRow('Address', _patient?.address ?? 'Not provided'),
                _DetailRow('Blood Group', _patient?.bloodGroup ?? 'Not provided'),
                _DetailRow('Allergies', _patient?.allergies ?? 'None recorded'),
                _DetailRow('Medical History', _patient?.medicalHistory ?? 'Not provided'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle('Visit History'),
          const AppCard(
            child: Column(
              children: [
                _VisitRow('05 Sep 2026', 'Follow-up'),
                Divider(height: 22),
                _VisitRow('20 Aug 2026', 'New Visit'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'New Visit / Follow-up',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewVisitScreen(patientName: widget.patientName),
                  ),
                ),
          ),
        ],
      ],
    ),
  );

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static DateTime? _parseDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _VisitRow extends StatelessWidget {
  const _VisitRow(this.date, this.type);
  final String date;
  final String type;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.event_note_outlined, color: AppColors.teal, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Text(type, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );
}
