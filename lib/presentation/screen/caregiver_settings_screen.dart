import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alzhimers_ease/l10n/app_localizations.dart';
import '../../core/theme/theme_controller.dart';
import '../../provider/settings_provider.dart';

class CaregiverSettingsScreen extends StatefulWidget {
  final String? patientId;

  const CaregiverSettingsScreen({super.key, this.patientId});

  @override
  State<CaregiverSettingsScreen> createState() =>
      _CaregiverSettingsScreenState();
}

class _CaregiverSettingsScreenState extends State<CaregiverSettingsScreen> {
  String? _activePatientId;

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idToUse =
    (widget.patientId != null && widget.patientId!.isNotEmpty)
        ? widget.patientId
        : prefs.getString('registered_patient_id');

    if (!mounted) return;

    if (idToUse != null && idToUse.isNotEmpty) {
      setState(() {
        _activePatientId = idToUse;
      });
      ThemeController.instance.listenToPatientTheme(idToUse);
      Provider.of<SettingsProvider>(context, listen: false)
          .initializeFirestoreSync(idToUse);
    }
  }

  /// Syncs language preferences directly to Firestore for real-time patient updates
  Future<void> _syncLanguageToFirestore(String langCode) async {
    if (_activePatientId != null && _activePatientId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(_activePatientId)
            .set({
          'preferredLanguage': langCode,
          'appLanguage': langCode,
          'lastSettingsUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error syncing language to Firestore: $e");
      }
    }
  }

  /// Syncs emergency contacts directly to Firestore for Patient SOS retrieval
  Future<void> _addEmergencyContactToFirestore(
      String name, String phone, String relation) async {
    if (_activePatientId != null && _activePatientId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(_activePatientId)
            .collection('emergency_contacts')
            .add({
          'name': name,
          'phoneNumber': phone,
          'relation': relation,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint("Error adding emergency contact to Firestore: $e");
      }
    }
  }

  /// Launches the Privacy Policy URL with multi-stage fallbacks
  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    const String privacyPolicyUrl =
        'https://zainabatiq7.github.io/alzheimers-ease-privacy/';
    final Uri url = Uri.parse(privacyPolicyUrl);

    try {
      // Stage 1: Try In-App Browser Tab
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
      );

      // Stage 2: Fallback to External System Browser
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }

      // Stage 3: Fallback to Platform Default
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Privacy Policy in browser.'),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error launching Privacy Policy URL: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening browser: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.caregiverSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (context, _) {
          final themeController = ThemeController.instance;

          return SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              children: [
                // 1. APPEARANCE & ACCESSIBILITY
                _buildCardGroup(
                  context,
                  title: l10n.sectionAppearanceAccessibility,
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n.appAndPatientDarkMode,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.syncsDarkThemeSubtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      value: settings.isDarkMode || themeController.isDarkMode,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (bool val) {
                        settings.toggleTheme(val);
                        if (_activePatientId != null) {
                          themeController.updateThemeSettings(
                            patientId: _activePatientId!,
                            isDark: val,
                            themePresetId: 'teal_soothe',
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(
                        l10n.fontTextScale,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.fontScaleSubtitle(
                          (settings.fontSizeScale * 100).toInt().toString(),
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      trailing: DropdownButton<double>(
                        value: settings.fontSizeScale,
                        underline: const SizedBox(),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (double? newScale) {
                          if (newScale != null) {
                            settings.setFontSizeScale(newScale);
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: 1.0,
                            child: Text(l10n.fontSizeNormal),
                          ),
                          DropdownMenuItem(
                            value: 1.2,
                            child: Text(l10n.fontSizeLarge),
                          ),
                          DropdownMenuItem(
                            value: 1.4,
                            child: Text(l10n.fontSizeExtraLarge),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. EMERGENCY CONTACTS
                _buildCardGroup(
                  context,
                  title: l10n.sectionEmergencyContacts,
                  children: [
                    if (settings.emergencyContacts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.noEmergencyContacts,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      ...settings.emergencyContacts.map(
                            (contact) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${contact.relation} • ${contact.phone}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                settings.removeEmergencyContact(contact.id),
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.add_circle_outline,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n.addNewEmergencyContact,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showAddContactModal(context, settings),
                    ),
                  ],
                ),

                // 3. NOTIFICATIONS & ALERTS
                _buildCardGroup(
                  context,
                  title: l10n.sectionNotificationsAudio,
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n.pushNotifications,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.pushNotificationsSubtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      value: settings.notificationsEnabled,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) => settings.toggleNotifications(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        l10n.bypassDoNotDisturb,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.bypassDndSubtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      value: settings.bypassDnd,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) => settings.toggleBypassDnd(val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(
                        l10n.emergencyRingtone,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        settings.alertTone,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: settings.alertTone,
                        underline: const SizedBox(),
                        dropdownColor: theme.cardColor,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (String? newTone) {
                          if (newTone != null) settings.setAlertTone(newTone);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'Default Emergency Chime',
                            child: Text(l10n.toneChime),
                          ),
                          DropdownMenuItem(
                            value: 'Loud Siren Alert',
                            child: Text(l10n.toneSiren),
                          ),
                          DropdownMenuItem(
                            value: 'Soft Medical Pulse',
                            child: Text(l10n.tonePulse),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 4. LANGUAGE & PREFERENCES
                _buildCardGroup(
                  context,
                  title: l10n.sectionLanguageLocalization,
                  children: [
                    ListTile(
                      title: Text(
                        l10n.appLanguageLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        l10n.activeLanguageStatus,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.language,
                        color: colorScheme.primary,
                      ),
                      onTap: () {
                        final newLang =
                        settings.languageCode == 'ur' ? 'en' : 'ur';
                        settings.setLanguage(newLang);
                        _syncLanguageToFirestore(newLang);
                      },
                    ),
                  ],
                ),

                // 5. ABOUT APP & COMPLIANCE
                _buildCardGroup(
                  context,
                  title: l10n.sectionAboutCompliance,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n.aboutAlzheimersEase,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.aboutAlzheimersEaseSubtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => _showAboutAppDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        l10n.privacyPolicyTitle,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(
                        Icons.open_in_new,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () => _launchPrivacyPolicy(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        l10n.deleteAccountTitle,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        l10n.deleteAccountSubtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l10n.appFooterCredits,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardGroup(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.8,
                color: colorScheme.primary,
              ),
            ),
          ),
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContactModal(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addEmergencyContactTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: l10n.fullNameLabel,
                  hintText: l10n.fullNameHint,
                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? l10n.enterValidNameError
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+923001234567',
                  prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? l10n.enterValidPhoneError
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: relationController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: l10n.relationLabel,
                  hintText: l10n.relationHint,
                  prefixIcon: Icon(Icons.people_outline, color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final name = nameController.text.trim();
                      final phone = phoneController.text.trim();
                      final relation = relationController.text.trim().isEmpty
                          ? 'Contact'
                          : relationController.text.trim();

                      settings.addEmergencyContact(name, phone, relation);
                      _addEmergencyContactToFirestore(name, phone, relation);
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    l10n.saveContactButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: "Alzheimer's Ease",
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.health_and_safety,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 12),
        Text(l10n.aboutAppDetailedDescription),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.deleteAccountRequestSubmittedSnackbar,
                  ),
                ),
              );
            },
            child: Text(
              l10n.deletePermanentlyButton,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}