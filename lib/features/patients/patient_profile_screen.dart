import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../visits/new_visit_screen.dart';

class PatientProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(isNew ? 'New Patient' : 'Patient Profile'),
      actions: [
        if (!isNew)
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Row(
            children: [
              const InitialAvatar('R'),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNew ? 'New patient' : patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    isNew
                        ? 'Complete patient details'
                        : '$patientId  •  Male, 31 Y',
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
        if (isNew) ...[
          const AppTextField(label: 'Full Name', hint: 'Enter patient name'),
          const SizedBox(height: 14),
          const AppTextField(
            label: 'Mobile Number',
            hint: 'Enter mobile number',
          ),
          const SizedBox(height: 14),
          const AppTextField(label: 'Date of Birth', hint: 'DD/MM/YYYY'),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save Patient', onPressed: null),
        ] else ...[
          const SectionTitle('Patient Details'),
          const AppCard(
            child: Column(
              children: [
                _DetailRow('Date of Birth', '12 Aug 1991'),
                _DetailRow('Address', '25, MG Road, Delhi'),
                _DetailRow('Blood Group', 'B+'),
                _DetailRow('Allergies', 'No known allergies'),
                _DetailRow('Medical History', 'Hypertension'),
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
                    builder: (_) => NewVisitScreen(patientName: patientName),
                  ),
                ),
          ),
        ],
      ],
    ),
  );
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
