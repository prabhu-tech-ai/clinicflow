import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../shell/app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 54, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.add_circle_outline,
                color: AppColors.teal,
                size: 52,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Please login to continue',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 44),
            AppTextField(
              label: 'User ID',
              hint: 'Enter user id',
              icon: Icons.person_outline,
              controller: _userController,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Password',
              hint: 'Enter password',
              icon: Icons.lock_outline,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_box_outline_blank,
                  size: 18,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Remember me',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 12, color: AppColors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Login',
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AppShell()),
                  ),
            ),
            const SizedBox(height: 34),
            const Center(
              child: Text(
                'Login as',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _RoleTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _RoleTile(icon: Icons.person_outline, label: 'Doctor'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _RoleTile(
                    icon: Icons.support_agent,
                    label: 'Reception',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Icon(icon, color: AppColors.teal),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
