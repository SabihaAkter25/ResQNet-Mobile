import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                          AppTheme.primaryRed.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'INCISYNC User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Guest Account',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'GUEST',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionTitle('Account'),

              _buildMenuItem(
                icon: Icons.history_rounded,
                title: 'My Reports',
                subtitle: 'View your submitted disaster reports',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Open the History tab to view reports.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildSectionTitle('General'),

              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage emergency notifications',
                onTap: () => _showComingSoon(context),
              ),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences and configuration',
                onTap: () => _showComingSoon(context),
              ),

              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Get help using INCISYNC',
                onTap: () => _showComingSoon(context),
              ),

              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'About INCISYNC',
                subtitle: 'Learn more about this application',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'INCISYNC',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'A Disaster Reporting and Emergency Response System.',
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'INCISYNC • Report • Alert • Respond',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: AppTheme.primaryRed,
          size: 25,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon.'),
      ),
    );
  }
}
