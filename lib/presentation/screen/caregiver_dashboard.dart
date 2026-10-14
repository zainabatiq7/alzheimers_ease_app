import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import 'register_patient_screen.dart';
import 'caregiver/patient_control_deck.dart';
import 'caregiver_settings_screen.dart';
import 'package:alzhimers_ease/data/services/notification_service.dart';
import 'package:alzhimers_ease/presentation/widgets/dynamic_translated_text.dart';
import 'package:alzhimers_ease/core/theme/app_theme.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  bool _isLoading = true;
  List<String> _linkedPatientIds = [];
  String? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    _saveCaregiverDeviceToken();
    NotificationService().initNotificationListeners(context);
    _fetchAllLinkedPatients();
  }

  void _saveCaregiverDeviceToken() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      NotificationService().saveDeviceToken(
        userId: currentUser.uid,
        userType: 'caregivers',
      );
    }
  }

  /// Fetches ALL patients linked to this caregiver UID (supports caregiverIds array & caregiverUid fallback)
  Future<void> _fetchAllLinkedPatients() async {
    setState(() => _isLoading = true);
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        QuerySnapshot query = await FirebaseFirestore.instance
            .collection('patients')
            .where('caregiverIds', arrayContains: currentUser.uid)
            .get();

        if (query.docs.isEmpty) {
          query = await FirebaseFirestore.instance
              .collection('patients')
              .where('caregiverUid', isEqualTo: currentUser.uid)
              .get();
        }

        if (!mounted) return;

        if (query.docs.isNotEmpty) {
          final List<String> patientIds = query.docs.map((doc) => doc.id).toList();

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String? lastSelectedId = prefs.getString('registered_patient_id');

          setState(() {
            _linkedPatientIds = patientIds;
            _selectedPatientId = (lastSelectedId != null && patientIds.contains(lastSelectedId))
                ? lastSelectedId
                : patientIds.first;
          });

          if (_selectedPatientId != null) {
            await prefs.setString('registered_patient_id', _selectedPatientId!);
          }
        } else {
          setState(() {
            _linkedPatientIds = [];
            _selectedPatientId = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching linked patients: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectPatient(String patientId) async {
    setState(() => _selectedPatientId = patientId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_patient_id', patientId);
  }

  Future<void> _deletePatientProfile(String patientId, String patientName) async {
    final loc = AppLocalizations.of(context)!;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Profile - $patientName"),
        content: Text(
          "Are you sure you want to remove $patientName from your dashboard? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      final DocumentReference patientRef =
      FirebaseFirestore.instance.collection('patients').doc(patientId);

      final DocumentSnapshot snapshot = await patientRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> caregiverIds = data['caregiverIds'] ?? [];

        if (caregiverIds.length > 1) {
          await patientRef.update({
            'caregiverIds': FieldValue.arrayRemove([currentUser.uid]),
          });
        } else {
          await patientRef.delete();
        }
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> localIds = prefs.getStringList('registered_patient_ids_list') ?? [];
      localIds.remove(patientId);
      await prefs.setStringList('registered_patient_ids_list', localIds);
      await prefs.remove('patient_password_$patientId');

      if (prefs.getString('registered_patient_id') == patientId) {
        await prefs.remove('registered_patient_id');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Patient profile removed: $patientName"),
          backgroundColor: Colors.orange,
        ),
      );

      _fetchAllLinkedPatients();
    } catch (e) {
      debugPrint("Error deleting patient profile: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete patient profile: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.caregiverHub, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: loc.settings,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaregiverSettingsScreen(
                    patientId: _selectedPatientId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: loc.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.welcomeToCarePortal,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.activeMonitoringSession,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_linkedPatientIds.isNotEmpty)
                    Text(
                      "${_linkedPatientIds.length} ${loc.defaultPatientRole}(s)",
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPatientListSection(loc),
              const SizedBox(height: 24),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 16),
              Text(
                loc.caregiverActions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.person_add_alt_1_rounded,
                title: loc.registerNewPatient,
                subtitle: loc.registerNewPatientSubtitle,
                accentColor: AppTheme.lightPrimaryAccent,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPatientScreen(initialMode: true),
                    ),
                  );
                  if (mounted) _fetchAllLinkedPatients();
                },
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.swap_horizontal_circle_outlined,
                title: loc.connectExistingPatient,
                subtitle: loc.connectExistingPatientSubtitle,
                accentColor: AppTheme.lightSecondaryAccent,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPatientScreen(initialMode: false),
                    ),
                  );
                  if (mounted) _fetchAllLinkedPatients();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientListSection(AppLocalizations loc) {
    final theme = Theme.of(context);

    if (_linkedPatientIds.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor),
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.no_accounts_outlined, size: 56, color: theme.disabledColor),
              const SizedBox(height: 12),
              Text(
                loc.noPatientActive,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _linkedPatientIds.map((patientId) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildPatientCard(patientId, loc),
        );
      }).toList(),
    );
  }

  Widget _buildPatientCard(String patientId, AppLocalizations loc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final String currentLang = Localizations.localeOf(context).languageCode;
    final bool isSelected = patientId == _selectedPatientId;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('patients').doc(patientId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        // Safely extract and format patient map
        final rawData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final Map<String, dynamic> patientData = Map<String, dynamic>.from(rawData);
        patientData['patientId'] = snapshot.data!.id;

        final String patientName = patientData['name'] ?? loc.unknown;
        final String? rawPhotoUrl = patientData['patientPhotoUrl'] as String?;
        final bool hasValidPhoto = rawPhotoUrl != null && rawPhotoUrl.trim().isNotEmpty;

        // Calculate pending tasks dynamically to remain consistent with Care Plan Manager schema
        final int totalTasks = patientData['totalTasks'] ?? 0;
        final int completedTasks = patientData['completedTasks'] ?? 0;
        final int pendingTasks = (totalTasks - completedTasks).clamp(0, 999);

        final String lastActivity = patientData['lastCompletedTask'] ?? loc.noActiveLogUpdates;

        return Card(
          elevation: isSelected ? 2 : 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? colorScheme.primary : theme.dividerColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectPatient(patientId),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Patient Profile Photo Circle
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                        backgroundImage: hasValidPhoto ? NetworkImage(rawPhotoUrl) : null,
                        child: !hasValidPhoto
                            ? Text(
                          patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DynamicTranslatedText(
                              text: patientName,
                              targetLanguageCode: currentLang,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.patientAgeAndRelation(
                                patientData['age']?.toString() ?? '',
                                patientData['relation'] ?? '',
                              ),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colorScheme.error),
                        tooltip: "Delete Patient",
                        onPressed: () => _deletePatientProfile(patientId, patientName),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.getPrimaryGradient(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _selectPatient(patientId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientControlDeckScreen(patientData: patientData),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(loc.launch, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                loc.taskStatusUpdates,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pendingTasks == 0
                              ? (isDark ? AppTheme.darkSecondaryAccent : AppTheme.lightSecondaryAccent).withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pendingTasks <= 0 ? loc.allDone : loc.pendingTasksCount(pendingTasks),
                          style: TextStyle(
                            color: pendingTasks <= 0
                                ? (isDark ? AppTheme.darkSecondaryAccent : AppTheme.lightSecondaryAccent)
                                : Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.history_toggle_off_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          loc.activityLog(lastActivity),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 26, color: accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}