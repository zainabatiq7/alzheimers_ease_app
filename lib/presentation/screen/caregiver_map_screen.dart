import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverMapScreen extends StatefulWidget {
  final String patientId;

  const CaregiverMapScreen({super.key, required this.patientId});

  @override
  State<CaregiverMapScreen> createState() => _CaregiverMapScreenState();
}

class _CaregiverMapScreenState extends State<CaregiverMapScreen> {
  final MapController _mapController = MapController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic dimensions based on screen orientation & width
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Safety & Geofence"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('patients').doc(widget.patientId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading location data."));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: CircularProgressIndicator());
            }

            var patientData = snapshot.data!.data() as Map<String, dynamic>;

            // Extract coordinates and geofence state from Firestore
            var liveLocation = patientData['liveLocation'] ?? {};
            double patientLat = (liveLocation['latitude'] as num?)?.toDouble() ?? 31.5204;
            double patientLng = (liveLocation['longitude'] as num?)?.toDouble() ?? 74.3587;

            var safeZone = patientData['safeZone'] ?? {};
            double safeZoneLat = (safeZone['latitude'] as num?)?.toDouble() ?? patientLat;
            double safeZoneLng = (safeZone['longitude'] as num?)?.toDouble() ?? patientLng;
            double safeZoneRadius = (safeZone['radiusMeters'] as num?)?.toDouble() ?? 200.0;

            bool isOutside = patientData['isOutsideSafeZone'] ?? false;
            int distanceFromHome = patientData['distanceFromHomeMeters'] ?? 0;

            LatLng patientPosition = LatLng(patientLat, patientLng);
            LatLng safeZoneCenter = LatLng(safeZoneLat, safeZoneLng);

            return Stack(
              children: [
                // 1. OpenStreetMap View
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: patientPosition,
                    initialZoom: 16.0,
                  ),
                  children: [
                    // Free OpenStreetMap Tile Layer
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.zainabkapoor.alzhimers_ease',
                    ),

                    // Geofence Visual Circle Overlay
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: safeZoneCenter,
                          radius: safeZoneRadius,
                          useRadiusInMeter: true, // Scales the circle dynamically with map zoom
                          color: (isOutside ? Colors.red : Colors.teal).withValues(alpha: 0.15),
                          borderColor: isOutside ? Colors.red : Colors.teal,
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),

                    // Map Markers (Patient Location + Home Base Center)
                    MarkerLayer(
                      markers: [
                        // Patient Marker
                        Marker(
                          point: patientPosition,
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.person_pin_circle,
                            color: isOutside ? Colors.red : Colors.blue,
                            size: 45,
                          ),
                        ),

                        // Home Base / Safe Zone Marker
                        Marker(
                          point: safeZoneCenter,
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

                // 2. Real-Time Security Status Alert Card (Overlay)
                Positioned(
                  top: 12,
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  child: Card(
                    elevation: 6,
                    color: isOutside ? Colors.red.shade900 : Colors.teal.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            isOutside ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isOutside ? "GEOFENCE BREACH ALERT" : "Patient in Safe Zone",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$distanceFromHome m from home (Safe limit: ${safeZoneRadius.toInt()} m)",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
            );
          },
        ),
      ),
    );
  }
}