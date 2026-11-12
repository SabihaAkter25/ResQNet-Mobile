import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../events/data/repositories/event_repository.dart';

class LiveMapPreview extends StatefulWidget {
  const LiveMapPreview({super.key});

  @override
  State<LiveMapPreview> createState() => _LiveMapPreviewState();
}

class _LiveMapPreviewState extends State<LiveMapPreview> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _isLoading = false;
  bool _mapReady = false;
  List<Marker> _disasterMarkers = [];

  static const LatLng _defaultLocation = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _findCurrentLocation();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await EventRepository().getActiveReports();

      final markers = reports.map((report) {
        final lat = (report['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (report['longitude'] as num?)?.toDouble() ?? 0.0;
        final eventType = report['event_type'] as String? ?? 'DISASTER';

        return Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 40,
          child: Tooltip(
            message: eventType,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 32,
            ),
          ),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _disasterMarkers = markers;
        });
      }
    } catch (_) {}
  }

  Future<void> _findCurrentLocation() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please turn on your device location.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Enable it from app settings.',
        );
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

      if (_mapReady) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _currentPosition == null
        ? null
        : LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );

    return Container(
      height: 240,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 12,
              minZoom: 5,
              maxZoom: 18,
              onMapReady: () {
                _mapReady = true;

                if (currentLocation != null) {
                  _mapController.move(currentLocation, 15);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.resqnet_app',
              ),
              MarkerLayer(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation,
                      width: 45,
                      height: 45,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 34,
                      ),
                    ),
                  ..._disasterMarkers,
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 17,
                    color: Colors.red,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Live Map',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 10,
            bottom: 35,
            child: FloatingActionButton.small(
              heroTag: 'map_current_location',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: _isLoading ? null : _findCurrentLocation,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
