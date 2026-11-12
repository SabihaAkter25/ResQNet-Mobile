
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/repositories/event_repository.dart';
import 'report_event_screen.dart';

class EventsFeedScreen extends StatefulWidget {
  const EventsFeedScreen({super.key});

  @override
  State<EventsFeedScreen> createState() => _EventsFeedScreenState();
}

class _EventsFeedScreenState extends State<EventsFeedScreen> {
  final EventRepository _repository = EventRepository();

  String selectedFilter = 'All';

  late Future<List<Map<String, Object?>>> _reportsFuture;

  final List<String> filters = [
    'All',
    'FLOOD',
    'FIRE',
    'EARTHQUAKE',
    'LANDSLIDE',
    'ACCIDENT',
    'STORM',
    'HEATWAVE',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = _repository.getSavedReports();
  }

  Future<void> _refreshReports() async {
    setState(_loadReports);
    await _reportsFuture;
  }

  Color severityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return const Color(0xFF8E1B25);
      case 'HIGH':
        return AppTheme.primaryRed;
      case 'MEDIUM':
        return const Color(0xFFE58A19);
      default:
        return const Color(0xFF16856B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackground,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.shield_rounded,
              color: AppTheme.primaryRed,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Disaster Feed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryRed,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load reports: ${snapshot.error}'),
            );
          }

          final allReports = snapshot.data ?? [];

          final reports = selectedFilter == 'All'
              ? allReports
              : allReports
              .where((r) => r['event_type'] == selectedFilter)
              .toList();

          return RefreshIndicator(
            color: AppTheme.primaryRed,
            onRefresh: _refreshReports,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const Text(
                  'Disaster Updates',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay informed. Help your community stay safe.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 22),

                _buildReportBanner(),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Reports',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${reports.length} reports',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final isSelected = selectedFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          selectedColor:
                          AppTheme.primaryRed.withValues(alpha: 0.15),
                          checkmarkColor: AppTheme.primaryRed,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryRed
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                if (reports.isEmpty)
                  _buildEmptyState()
                else
                  ...reports.map(_buildReportCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notice a disaster?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Help others by reporting an incident.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportEventScreen(),
                ),
              ).then((_) => _refreshReports());
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryRed,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, Object?> report) {
    final type = report['event_type']?.toString() ?? 'OTHER';
    final description = report['description']?.toString() ?? '';
    final latitude = report['latitude']?.toString() ?? 'N/A';
    final longitude = report['longitude']?.toString() ?? 'N/A';
    final status = report['sync_status']?.toString() ?? 'PENDING';
    final incidentStatus = report['status']?.toString() ?? 'ACTIVE';
    final createdAt = report['local_created_at']?.toString() ?? '';

    // Severity will come from the backend/ML service later.
    const severity = 'UNASSESSED';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDetails(
          type,
          description,
          latitude,
          longitude,
          status,
          incidentStatus,
          createdAt,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      type == 'FLOOD'
                          ? Icons.water_rounded
                          : type == 'FIRE'
                          ? Icons.local_fire_department_rounded
                          : Icons.warning_amber_rounded,
                      color: AppTheme.primaryRed,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(status),
                      const SizedBox(height: 5),
                      _buildIncidentStatusBadge(incidentStatus),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    'Severity: ',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    severity,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: severityColor('LOW'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.blueGrey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '$latitude, $longitude',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    'Details',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.primaryRed,
                  ),
                ],
              ),

              if (createdAt.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isSynced = status == 'SYNCED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isSynced
            ? Colors.green.withValues(alpha: 0.10)
            : Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isSynced ? Colors.green : Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIncidentStatusBadge(String status) {
    final Color color;

    switch (status) {
      case 'RESOLVED':
        color = Colors.green;
        break;
      case 'EXPIRED':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Reports Found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no reports in this category yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showDetails(
    String type,
    String description,
    String latitude,
    String longitude,
    String status,
    String incidentStatus,
    String createdAt,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disaster Report Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _detailRow('Event Type', type),
                _detailRow('Description', description),
                _detailRow('Latitude', latitude),
                _detailRow('Longitude', longitude),
                _detailRow('Sync Status', status),
                _detailRow('Incident Status', incidentStatus),
                _detailRow('Reported At', _formatDate(createdAt)),
                _detailRow('Severity', 'Not assessed yet'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
