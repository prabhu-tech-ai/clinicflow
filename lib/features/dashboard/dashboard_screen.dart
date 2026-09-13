import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../patients/patient_list_screen.dart';
import '../patients/patient_profile_screen.dart';
import '../visits/new_visit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
          pinned: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Tuesday, 5 Sep 2026',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.65,
                children: const [
                  _StatCard(
                    '25',
                    'Today\'s Patients',
                    Icons.people_outline,
                    AppColors.teal,
                  ),
                  _StatCard(
                    '10',
                    'New Patients',
                    Icons.person_add_alt_1_outlined,
                    Colors.orange,
                  ),
                  _StatCard(
                    '15',
                    'Follow-ups',
                    Icons.event_available_outlined,
                    Colors.deepPurple,
                  ),
                  _StatCard(
                    '5',
                    'Doctors',
                    Icons.medical_services_outlined,
                    Colors.indigo,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle('Quick Actions'),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'New Patient',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const PatientProfileScreen(isNew: true),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.favorite_border,
                      label: 'Follow-up',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewVisitScreen(),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'Prescription',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionTitle(
                'Recent Patients',
                action: 'View all',
                onAction:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatientListScreen(),
                      ),
                    ),
              ),
              const AppCard(
                child: Column(
                  children: [
                    _PatientRow(
                      name: 'Ramesh Kumar',
                      id: 'P000125',
                      time: 'Today, 09:30',
                    ),
                    Divider(height: 22),
                    _PatientRow(
                      name: 'Priya Sharma',
                      id: 'P000126',
                      time: 'Today, 10:15',
                    ),
                    Divider(height: 22),
                    _PatientRow(
                      name: 'Amit Singh',
                      id: 'P000127',
                      time: 'Yesterday',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(13),
    child: Row(
      children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.name, required this.id, required this.time});
  final String name;
  final String id;
  final String time;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const InitialAvatar('R'),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            Text(
              id,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
      Text(time, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
    ],
  );
}
