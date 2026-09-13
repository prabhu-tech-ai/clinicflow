import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('More', style: TextStyle(fontWeight: FontWeight.w700)),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.mint,
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.teal,
            size: 34,
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'Admin User',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
        ),
        const Center(
          child: Text(
            'admin@clinic.com',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 26),
        _SettingRow(Icons.settings_outlined, 'Settings'),
        _SettingRow(Icons.people_outline, 'Manage Doctors'),
        _SettingRow(Icons.sync_outlined, 'Sync & Backup'),
        _SettingRow(Icons.help_outline, 'Help & Support'),
        const SizedBox(height: 12),
        _SettingRow(Icons.logout, 'Logout', color: Colors.redAccent),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(this.icon, this.label, {this.color = AppColors.ink});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color),
    title: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    ),
    trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
    onTap: () {},
  );
}
