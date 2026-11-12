import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../../repositories/clinic_repository.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../patients/patient_profile_screen.dart';

enum DashboardMetric { todayPatients, newPatients, followUps, doctors }

class DashboardMetricScreen extends StatelessWidget {
  const DashboardMetricScreen({super.key, required this.metric});

  final DashboardMetric metric;

  String get _title => switch (metric) {
    DashboardMetric.todayPatients => "Today's Patients",
    DashboardMetric.newPatients => 'New Patients',
    DashboardMetric.followUps => 'Follow-ups',
    DashboardMetric.doctors => 'Doctors',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_title, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
    body: switch (metric) {
      DashboardMetric.todayPatients => _todayPatients(),
      DashboardMetric.newPatients => _newPatients(),
      DashboardMetric.followUps => _followUps(),
      DashboardMetric.doctors => _doctors(),
    },
  );

  Widget _todayPatients() => StreamBuilder<List<Visit>>(
    stream: clinicRepository.visits.watchVisits(),
    builder:
        (context, visitsSnapshot) => StreamBuilder<List<Patient>>(
          stream: clinicRepository.patients.watchPatients(),
          builder: (context, patientsSnapshot) {
            if (visitsSnapshot.hasError || patientsSnapshot.hasError) {
              return _errorState();
            }
            if (visitsSnapshot.connectionState == ConnectionState.waiting ||
                patientsSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingState();
            }
            final today = DateTime.now();
            final visits =
                (visitsSnapshot.data ?? const <Visit>[])
                    .where(
                      (visit) => _isSameDay(visit.visitDate.toLocal(), today),
                    )
                    .toList();
            final patientVisits = <String, int>{};
            for (final visit in visits) {
              patientVisits.update(
                visit.patientId,
                (count) => count + 1,
                ifAbsent: () => 1,
              );
            }
            final patients =
                (patientsSnapshot.data ?? const <Patient>[])
                    .where((patient) => patientVisits.containsKey(patient.id))
                    .toList();
            if (patients.isEmpty) {
              return _emptyState('No patients have visits today');
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final patient in patients)
                  _PatientCard(
                    patient: patient,
                    detail: '${patientVisits[patient.id]} visit(s) today',
                  ),
              ],
            );
          },
        ),
  );

  Widget _newPatients() => StreamBuilder<List<Patient>>(
    stream: clinicRepository.patients.watchPatients(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return _errorState();
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _loadingState();
      }
      final today = DateTime.now();
      final patients =
          (snapshot.data ?? const <Patient>[])
              .where(
                (patient) => _isSameDay(patient.createdAt.toLocal(), today),
              )
              .toList();
      if (patients.isEmpty) return _emptyState('No new patients today');
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final patient in patients)
            _PatientCard(patient: patient, detail: patient.patientCode),
        ],
      );
    },
  );

  Widget _followUps() => StreamBuilder<List<Visit>>(
    stream: clinicRepository.visits.watchVisits(),
    builder:
        (context, visitsSnapshot) => StreamBuilder<List<Patient>>(
          stream: clinicRepository.patients.watchPatients(),
          builder: (context, patientsSnapshot) {
            if (visitsSnapshot.hasError || patientsSnapshot.hasError) {
              return _errorState();
            }
            if (visitsSnapshot.connectionState == ConnectionState.waiting ||
                patientsSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingState();
            }
            final patientsById = {
              for (final patient in patientsSnapshot.data ?? const <Patient>[])
                patient.id: patient,
            };
            final followUps =
                (visitsSnapshot.data ?? const <Visit>[])
                    .where((visit) => visit.visitType == 'Follow-up')
                    .toList();
            if (followUps.isEmpty) return _emptyState('No follow-up visits');
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final visit in followUps)
                  _FollowUpCard(
                    visit: visit,
                    patient: patientsById[visit.patientId],
                  ),
              ],
            );
          },
        ),
  );

  Widget _doctors() => StreamBuilder<List<Doctor>>(
    stream: clinicRepository.staff.watchDoctors(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return _errorState();
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _loadingState();
      }
      final doctors = snapshot.data ?? const <Doctor>[];
      if (doctors.isEmpty) return _emptyState('No doctors added yet');
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final doctor in doctors)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    InitialAvatar(doctor.fullName[0].toUpperCase()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          if (doctor.specialization?.isNotEmpty ?? false)
                            Text(
                              doctor.specialization!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          if (doctor.phone?.isNotEmpty ?? false)
                            Text(
                              doctor.phone!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  static Widget _loadingState() =>
      const Center(child: CircularProgressIndicator());

  static Widget _errorState() =>
      const Center(child: Text('Unable to load this information'));

  static Widget _emptyState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: AppCard(child: Text(message)),
    ),
  );

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.detail});

  final Patient patient;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PatientProfileScreen(
                      patientName: patient.fullName,
                      patientId: patient.patientCode,
                    ),
              ),
            ),
        child: Row(
          children: [
            InitialAvatar(patient.fullName[0].toUpperCase()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    detail,
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
  );
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.visit, required this.patient});

  final Visit visit;
  final Patient? patient;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppCard(
      child: InkWell(
        onTap:
            patient == null
                ? null
                : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PatientProfileScreen(
                          patientName: patient!.fullName,
                          patientId: patient!.patientCode,
                        ),
                  ),
                ),
        child: Row(
          children: [
            InitialAvatar(
              patient?.fullName.substring(0, 1).toUpperCase() ?? '?',
              color: Colors.deepPurple,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient?.fullName ?? 'Patient not found',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    _formatDate(visit.visitDate.toLocal()),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (patient != null)
              const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';

  static String _month(int month) =>
      const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month - 1];
}
