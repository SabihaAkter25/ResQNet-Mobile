import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/theme/app_theme.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  Position? _currentPosition;
  bool _isGettingLocation = false;
  bool _isHolding = false;
  Timer? _holdTimer;

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please turn on your GPS.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

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

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _startHolding() {
    if (_currentPosition == null || _isGettingLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please detect your location first.'),
        ),
      );
      return;
    }

    setState(() => _isHolding = true);

    _holdTimer = Timer(
      const Duration(seconds: 2),
      _prepareSOS,
    );
  }

  void _stopHolding() {
    _holdTimer?.cancel();

    if (mounted && _isHolding) {
      setState(() => _isHolding = false);
    }
  }

  void _prepareSOS() {
    if (!mounted) return;

    setState(() => _isHolding = false);

    final position = _currentPosition!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS Request Prepared'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your emergency location has been detected.',
            ),
            const SizedBox(height: 12),
            Text('Latitude: ${position.latitude}'),
            Text('Longitude: ${position.longitude}'),
            const SizedBox(height: 16),
            const Text(
              'Backend is not connected yet. '
              'No SOS alert has been sent.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.primaryRed,
                size: 55,
              ),

              const SizedBox(height: 12),

              const Text(
                'Emergency SOS',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your location will be prepared '
                'for an emergency alert.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // SOS Button
              GestureDetector(
                onLongPressStart: (_) => _startHolding(),
                onLongPressEnd: (_) => _stopHolding(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryRed,
                    border: Border.all(
                      color: Colors.red.shade100,
                      width: 12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(
                          alpha: _isHolding ? 0.45 : 0.2,
                        ),
                        blurRadius: _isHolding ? 35 : 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sos_rounded,
                        color: Colors.white,
                        size: 65,
                      ),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                _isHolding
                    ? 'Keep holding...'
                    : 'Hold for 2 seconds',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              // Location Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primaryRed,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Your Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    if (_currentPosition != null) ...[
                      Text(
                        'Latitude: ${_currentPosition!.latitude}',
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Longitude: ${_currentPosition!.longitude}',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Location detected successfully',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ] else
                      const Text(
                        'Location not detected yet.',
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGettingLocation
                            ? null
                            : _getLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _isGettingLocation
                              ? 'Detecting Location...'
                              : 'Get My Location',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'This is a preparation screen. '
                'Emergency alerts will be sent after '
                'backend integration.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
