import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'package:alzhimers_ease/core/theme/app_theme.dart';

class RegisterPatientScreen extends StatefulWidget {
  final bool initialMode; // true = Register, false = Connect/Link

  const RegisterPatientScreen({super.key, this.initialMode = true});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _connectFormKey = GlobalKey<FormState>();

  late bool _isRegisterMode;
  bool _isUploading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Search & Link Controllers
  final TextEditingController _searchNameController = TextEditingController();
  final TextEditingController _connectPasswordController = TextEditingController();

  // Location / Safe Zone State
  LatLng _selectedHomeLocation = const LatLng(31.5204, 74.3587); // Default: Lahore
  double _safeZoneRadius = 200.0; // Default 200m radius
  final MapController _mapController = MapController();

  // Image Picking & Cropping
  File? _patientImage;
  File? _caregiverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _relationController.dispose();
    _passwordController.dispose();
    _searchNameController.dispose();
    _connectPasswordController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Fetch phone GPS location to center map at current position
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (mounted) {
          setState(() {
            _selectedHomeLocation = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_selectedHomeLocation, 15.0);
        }
      }
    } catch (e) {
      debugPrint("Could not fetch current GPS location: $e");
    }
  }

  /// Pick and Crop Image with square aspect ratio and theme colors
  Future<void> _pickAndCropImage(bool isPatient) async {
    final colorScheme = Theme.of(context).colorScheme;

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 75,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: colorScheme.primary,
          toolbarWidgetColor: colorScheme.onPrimary,
          activeControlsWidgetColor: colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      setState(() {
        if (isPatient) {
          _patientImage = File(croppedFile.path);
        } else {
          _caregiverImage = File(croppedFile.path);
        }
      });
    }
  }

  Future<String> _uploadImage(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      return '';
    }
  }

  /// Helper to store patient ID and password in local device storage
  Future<void> _savePatientIdLocally(String patientId, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('registered_patient_id', patientId);
    await prefs.setString('patient_password_$patientId', password);
    await prefs.setString('registered_patient_password', password);

    List<String> patientIds = prefs.getStringList('registered_patient_ids_list') ?? [];
    if (!patientIds.contains(patientId)) {
      patientIds.add(patientId);
      await prefs.setStringList('registered_patient_ids_list', patientIds);
    }
  }

  Future<void> _registerNewPatient() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (!_formKey.currentState!.validate()) return;
    if (_patientImage == null) {
      _showSnackBar(l10n.pickProfilePhotoPrompt, colorScheme.error);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final User? caregiverUser = FirebaseAuth.instance.currentUser;
      if (caregiverUser == null) throw Exception("No logged-in caregiver found");

      final String patientId = FirebaseFirestore.instance.collection('patients').doc().id;
      final String enteredPassword = _passwordController.text.trim();
      final String patientEmail = "patient_$patientId@app.com";

      // 1. Create Dedicated Firebase Auth Account for Patient in Background
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: patientEmail,
          password: enteredPassword,
        );
      } catch (authError) {
        debugPrint("Patient Firebase Auth Creation Notice: $authError");
      }

      // 2. Upload Cropped Images
      String patientPhotoUrl = await _uploadImage(
        _patientImage!,
        'photos/patients/$patientId/profile.jpg',
      );

      String caregiverPhotoUrl = '';
      if (_caregiverImage != null) {
        caregiverPhotoUrl = await _uploadImage(
          _caregiverImage!,
          'photos/caregivers/${caregiverUser.uid}/profile.jpg',
        );
      }

      // 3. Prepare Patient Document Payload
      final Map<String, dynamic> patientPayload = {
        'patientId': patientId,
        'caregiverId': caregiverUser.uid,
        'caregiverUid': caregiverUser.uid,
        'caregiverIds': [caregiverUser.uid],
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'relation': _relationController.text.trim(),
        'password': enteredPassword,
        'email': patientEmail,
        'patientPhotoUrl': patientPhotoUrl,
        'caregiverPhotoUrl': caregiverPhotoUrl,
        'createdAt': FieldValue.serverTimestamp(),

        // Safe Zone Configuration
        'safeZone': {
          'latitude': _selectedHomeLocation.latitude,
          'longitude': _selectedHomeLocation.longitude,
          'radiusMeters': _safeZoneRadius,
        },

        // Initial Live Location
        'liveLocation': {
          'latitude': _selectedHomeLocation.latitude,
          'longitude': _selectedHomeLocation.longitude,
          'lastUpdated': FieldValue.serverTimestamp(),
        },

        'isOutsideSafeZone': false,
        'distanceFromHomeMeters': 0,
        'pendingTasks': 0,
        'lastCompletedTask': 'Profile registered',
      };

      // 4. Save to Firestore Database
      await FirebaseFirestore.instance.collection('patients').doc(patientId).set(patientPayload);

      // 5. Save Credentials Locally
      await _savePatientIdLocally(patientId, enteredPassword);

      if (!mounted) return;

      _showSnackBar(l10n.patientRegisteredSuccess, colorScheme.primary);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(l10n.registrationFailedError(e.toString()), colorScheme.error);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _connectExistingPatient() async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (!_connectFormKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Caregiver authorization expired");

      final String searchName = _searchNameController.text.trim();
      final String inputPassword = _connectPasswordController.text.trim();

      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('patients')
          .where('name', isEqualTo: searchName)
          .limit(1)
          .get();

      if (!mounted) return;

      if (query.docs.isEmpty) {
        _showSnackBar(l10n.noPatientFoundNameError, colorScheme.error);
        return;
      }

      final DocumentSnapshot doc = query.docs.first;
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['password'] != inputPassword) {
        _showSnackBar(l10n.incorrectPasswordError, colorScheme.error);
        return;
      }

      await FirebaseFirestore.instance.collection('patients').doc(doc.id).update({
        'caregiverId': user.uid,
        'caregiverUid': user.uid,
        'caregiverIds': FieldValue.arrayUnion([user.uid]),
      });

      await _savePatientIdLocally(doc.id, inputPassword);

      if (!mounted) return;

      _showSnackBar(l10n.successfullyConnectedTo(data['name'] ?? ''), colorScheme.primary);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(l10n.failedToLinkProfileError(e.toString()), colorScheme.error);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isRegisterMode ? l10n.registerNewPatientTitle : l10n.connectExistingPatientTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isUploading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                l10n.savingRecordsUploadingPhotos,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Control Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isRegisterMode = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: _isRegisterMode
                                ? AppTheme.getPrimaryGradient(context)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.registerNewTab,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isRegisterMode
                                  ? (theme.brightness == Brightness.dark
                                  ? AppTheme.darkBackgroundColor
                                  : Colors.white)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isRegisterMode = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: !_isRegisterMode
                                ? AppTheme.getPrimaryGradient(context)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.linkRegisteredTab,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_isRegisterMode
                                  ? (theme.brightness == Brightness.dark
                                  ? AppTheme.darkBackgroundColor
                                  : Colors.white)
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _isRegisterMode ? _buildRegisterForm(screenHeight) : _buildConnectForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(double screenHeight) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo Pickers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoPickerTile(
                isPatient: true,
                imageFile: _patientImage,
                title: l10n.patientPhotoRequired,
                primaryColor: isDark ? AppTheme.darkPrimaryAccent : AppTheme.lightPrimaryAccent,
              ),
              _buildPhotoPickerTile(
                isPatient: false,
                imageFile: _caregiverImage,
                title: l10n.yourPhotoCaregiver,
                primaryColor: isDark ? AppTheme.darkSecondaryAccent : AppTheme.lightSecondaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form Fields Card Scaffolding
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.patientNameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.ageLabel,
                      prefixIcon: const Icon(Icons.cake_outlined),
                    ),
                    validator: (v) =>
                    v == null || int.tryParse(v.trim()) == null ? l10n.enterValidAgeError : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _relationController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.relationshipToPatientLabel,
                      prefixIcon: const Icon(Icons.family_restroom_outlined),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.relationshipRequiredHint : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.patientPortalAccessPasswordLabel,
                      helperText: l10n.passwordFailHelperText,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != null && v.length >= 6 ? null : l10n.passwordLengthError,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Safe Zone Header & Map Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.setHomeAndSafeZone,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.my_location, size: 20),
                tooltip: l10n.useCurrentGpsLocationTooltip,
                onPressed: _getCurrentLocation,
              ),
            ],
          ),
          Text(
            l10n.tapMapSetHomeBaseHint,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // OpenStreetMap Container
          Container(
            height: screenHeight * 0.30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedHomeLocation,
                  initialZoom: 15.0,
                  onTap: (_, point) {
                    setState(() {
                      _selectedHomeLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.zainabkapoor.alzhimers_ease',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _selectedHomeLocation,
                        radius: _safeZoneRadius,
                        useRadiusInMeter: true,
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: colorScheme.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedHomeLocation,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.home, color: colorScheme.primary, size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Safe Zone Distance Slider
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allowedSafeDistanceLabel(_safeZoneRadius.toInt()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Slider(
                    value: _safeZoneRadius,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: colorScheme.primary,
                    label: "${_safeZoneRadius.toInt()}m",
                    onChanged: (val) {
                      setState(() {
                        _safeZoneRadius = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _registerNewPatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.registerPatientAndSaveLocationButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPickerTile({
    required bool isPatient,
    required File? imageFile,
    required String title,
    required Color primaryColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pickAndCropImage(isPatient),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor.withValues(alpha: 0.12),
                backgroundImage: imageFile != null ? FileImage(imageFile) : null,
                child: imageFile == null
                    ? Icon(Icons.person_add_alt_1_rounded, size: 32, color: primaryColor)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: Icon(Icons.crop_rotate_rounded, size: 14, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectForm() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _connectFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(Icons.cloud_sync_outlined, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            l10n.connectToExistingPatientHeader,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.connectPatientDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchNameController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.fullRegisteredPatientNameLabel,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.enterPatientSearchNameError : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _connectPasswordController,
                    obscureText: true,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: l10n.validationPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.enterPasswordError : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: _connectExistingPatient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.validateAndLinkProfileButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}