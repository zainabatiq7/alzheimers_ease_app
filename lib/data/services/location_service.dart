import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// 1. Check and request GPS location permissions
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled on device
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    return true;
  }

  /// 2. Start continuous GPS tracking for the Patient
  void startPatientLocationStream({
    required String patientId,
    required double safeZoneLat,
    required double safeZoneLng,
    required double safeZoneRadiusMeters,
  }) async {
    bool hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return;

    // High accuracy settings optimized for patient safety
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Triggers every 5 meters moved
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _processLocationUpdate(
        patientId: patientId,
        currentLat: position.latitude,
        currentLng: position.longitude,
        safeZoneLat: safeZoneLat,
        safeZoneLng: safeZoneLng,
        safeZoneRadiusMeters: safeZoneRadiusMeters,
      );
    });
  }

  /// 3. Haversine Distance Calculation & Firestore Synchronization
  void _processLocationUpdate({
    required String patientId,
    required double currentLat,
    required double currentLng,
    required double safeZoneLat,
    required double safeZoneLng,
    required double safeZoneRadiusMeters,
  }) async {
    // Trigonometric Haversine calculation performed on device
    double distanceInMeters = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      safeZoneLat,
      safeZoneLng,
    );

    // Determine if boundary is breached
    bool isOutside = distanceInMeters > safeZoneRadiusMeters;

    // Update real-time Firestore record under patient profile
    await _firestore.collection('patients').doc(patientId).update({
      'liveLocation': {
        'latitude': currentLat,
        'longitude': currentLng,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      'distanceFromHomeMeters': distanceInMeters.round(),
      'isOutsideSafeZone': isOutside,
    });
  }

  /// 4. Stop tracking stream when logging out or closing screen
  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}