import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/widgets/resqnet_logo.dart';
import '../../../emergency_contacts/presentation/screens/emergency_contacts_screen.dart';
import '../../../events/presentation/screens/events_feed_screen.dart';
import '../../../events/presentation/screens/my_reports_screen.dart';
import '../../../hospitals/presentation/screens/nearby_hospitals_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../sos/presentation/screens/sos_screen.dart';
import '../widgets/live_map_preview.dart';

/// Home Dashboard UI Screen for ResQNet.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: prefer_final_fields
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: (_currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3)
          ? null
          : AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: const Row(
                children: [
                  ResQNetLogo(
                    size: 26,
                    showText: false,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'INCISYNC',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF334155),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: _currentIndex == 1
          ? const EventsFeedScreen()
          : _currentIndex == 2
              ? const MyReportsScreen()
              : _currentIndex == 3
                  ? const ProfileScreen()
                  : SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(),
                            const SizedBox(height: 20),
                            _buildSosButton(context),
                            const SizedBox(height: 24),
                            _buildMapPreviewCard(),
                            const SizedBox(height: 24),
                            const Text(
                              'Emergency Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    title: 'Active Events',
                                    subtitle: '3 Alerts Nearby',
                                    icon: Icons.warning_amber_rounded,
                                    iconBgColor:
                                        AppTheme.primaryRed.withValues(alpha: 0.12),
                                    iconColor: AppTheme.primaryRed,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NearbyHospitalsScreen(),
                                        ),
                                      );
                                    },
                                    child: _buildSummaryCard(
                                      title: 'Nearby Hospitals',
                                      subtitle: 'Find Hospitals',
                                      icon: Icons.local_hospital_rounded,
                                      iconBgColor:
                                          const Color(0xFF0288D1).withValues(alpha: 0.12),
                                      iconColor: const Color(0xFF0288D1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EmergencyContactsScreen(),
                                        ),
                                      );
                                    },
                                    child: _buildSummaryCard(
                                      title: 'Emergency Contacts',
                                      subtitle: 'Trusted People',
                                      icon: Icons.contact_phone_rounded,
                                      iconBgColor: const Color(0xFFE53935).withValues(alpha: 0.12),
                                      iconColor: const Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
    );
  }

  /// Glassmorphic Welcome heading card
  Widget _buildWelcomeHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stay Safe, Rescuer 👋',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stay alert. Real-time disaster reports and community aid resources are available nearby.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Prominent Red SOS Emergency Button with Glassmorphic feel
  Widget _buildSosButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryRed,
            Color(0xFFB91C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withValues(alpha: 0.38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SosScreen(),
            ),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos_rounded, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'EMERGENCY SOS',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Map Preview Card Placeholder
  Widget _buildMapPreviewCard() {
    return const LiveMapPreview();
  }

  /// Reusable Glassmorphic Summary Card Component
  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
