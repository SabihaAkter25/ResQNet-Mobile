import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_theme.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() =>
      _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState
    extends State<NearbyHospitalsScreen> {
  Position? _position;
  bool _isLoading = false;

  Future<void> _findHospitals() async {
    setState(() => _isLoading = true);

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please turn on GPS.');
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      setState(() => _position = position);

      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=hospitals+near+${position.latitude},${position.longitude}',
      );

      bool opened = false;
      if (await canLaunchUrl(mapsUrl)) {
        opened = await launchUrl(
          mapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        opened = await launchUrl(
          mapsUrl,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!opened && mounted) {
        throw Exception('Could not open Google Maps.');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Nearby Hospitals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0288D1)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        size: 48,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Find Hospitals Near You',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Detect your current location and '
                      'find nearby hospitals using Google Maps.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading ? null : _findHospitals,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isLoading
                              ? 'Finding Hospitals...'
                              : 'Find Nearby Hospitals',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Your Current Location',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.primaryRed,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _position == null
                          ? const Text(
                              'Location not detected yet.',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lat: ${_position!.latitude}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Long: ${_position!.longitude}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'How it works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '1. Your phone detects your GPS location.\n'
                '2. Google Maps searches nearby hospitals.\n'
                '3. You can view hospital details and directions.',
                style: TextStyle(
                  height: 1.8,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
