import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class PatientReturnRouteScreen extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final double homeLat;
  final double homeLng;

  const PatientReturnRouteScreen({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.homeLat,
    required this.homeLng,
  });

  @override
  State<PatientReturnRouteScreen> createState() => _PatientReturnRouteScreenState();
}

class _PatientReturnRouteScreenState extends State<PatientReturnRouteScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _isLoading = true;
  String _routeDistance = "";
  String _routeDuration = "";

  @override
  void initState() {
    super.initState();
    _fetchWalkingDirectionsOSRM();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Fetches real walking route geometry using OpenSource Routing Machine (OSRM)
  Future<void> _fetchWalkingDirectionsOSRM() async {
    // OSRM expects coordinates in {longitude},{latitude} format
    final String url =
        'https://router.project-osrm.org/route/v1/foot/'
        '${widget.currentLng},${widget.currentLat};'
        '${widget.homeLng},${widget.homeLat}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];

          // Extract distance (meters) and duration (seconds)
          double distanceMeters = (route['distance'] as num).toDouble();
          double durationSeconds = (route['duration'] as num).toDouble();

          // Convert coordinates [lng, lat] from GeoJSON into LatLng points
          List<dynamic> coordinates = route['geometry']['coordinates'];
          List<LatLng> points = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          if (mounted) {
            setState(() {
              _routePoints = points;
              _routeDistance = distanceMeters > 1000
                  ? "${(distanceMeters / 1000).toStringAsFixed(1)} km"
                  : "${distanceMeters.round()} m";
              _routeDuration = "${(durationSeconds / 60).round()} mins";
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching OSRM walking route: $e");
      // Fallback: draw straight line if route API request fails
      if (mounted) {
        setState(() {
          _routePoints = [
            LatLng(widget.currentLat, widget.currentLng),
            LatLng(widget.homeLat, widget.homeLng),
          ];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final patientPos = LatLng(widget.currentLat, widget.currentLng);
    final homePos = LatLng(widget.homeLat, widget.homeLng);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Guide Me Home"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: patientPos,
                initialZoom: 16.0,
              ),
              children: [
                // Free OpenStreetMap Tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.zainabkapoor.alzhimers_ease',
                ),

                // Polyline overlay showing the walking path
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blueAccent,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),

                // Markers for Current Location and Home
                MarkerLayer(
                  markers: [
                    // Patient Location Marker
                    Marker(
                      point: patientPos,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 45,
                      ),
                    ),

                    // Home Base Marker
                    Marker(
                      point: homePos,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.home,
                        color: Colors.green,
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Responsive Walking route details overlay card
            if (!_isLoading && _routeDistance.isNotEmpty)
              Positioned(
                bottom: 20,
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.teal.shade900,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_walk_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Walking Directions Home",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Distance: $_routeDistance | Time: $_routeDuration",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}