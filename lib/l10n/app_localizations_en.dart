// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Alzheimer\'s Ease';

  @override
  String get splashTagline => 'Care & Connection';

  @override
  String get subtitle => 'Memory Protection & Patient Care Assistant';

  @override
  String get iAmCaregiver => 'I am a Caregiver';

  @override
  String get iAmPatient => 'I am a Patient';

  @override
  String get enterPatientPass => 'Enter Patient Password';

  @override
  String get passwordHint => 'Enter the password assigned by caregiver';

  @override
  String get login => 'Log In';

  @override
  String get cancel => 'Cancel';

  @override
  String get noPatientError =>
      'No patient is registered on this device! Please register from the caregiver panel.';

  @override
  String get invalidPassError => 'Invalid password! Please try again.';

  @override
  String get authFailed => 'Authentication failed. Try again.';

  @override
  String get useFingerprint =>
      'Scan your fingerprint to access your dashboard.';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get createAccount => 'Create Account';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields.';

  @override
  String get loggedInSuccess => 'Logged in successfully!';

  @override
  String get accountCreatedSuccess => 'Account created successfully!';

  @override
  String get authErrorOccurred => 'An error occurred during authentication.';

  @override
  String get unexpectedErrorOccurred => 'An unexpected error occurred.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get logIn => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log In';

  @override
  String get speakToType => 'Speak to type';

  @override
  String get myMemoryDiary => 'My Memory Diary';

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get myDayToday => 'My Day Today';

  @override
  String get myDayTodaySubtitle =>
      'Record how you\'re feeling, what you ate, and what you wore';

  @override
  String get beautifulMoments => 'Beautiful Moments';

  @override
  String get beautifulMomentsSubtitle =>
      'Photos, voice notes, and happy memories';

  @override
  String get whoVisitedMe => 'Who Visited Me';

  @override
  String get whoVisitedMeSubtitle =>
      'View recent visits and photos with loved ones';

  @override
  String get addABeautifulMoment => 'Add a Beautiful Moment';

  @override
  String get tapToAddPhoto => 'Tap to add a photo';

  @override
  String get whatMadeThisMomentSpecial => 'What made this moment special?';

  @override
  String get saveMoment => 'Save';

  @override
  String get addMoment => 'Add Moment';

  @override
  String get noMomentsRecordedYet =>
      'No moments recorded yet.\nTap + to save a new memory!';

  @override
  String get patientNote => 'Patient Note';

  @override
  String get caregiverNote => 'Caregiver Note';

  @override
  String get newMemoryTitle => 'New Memory Saved 📸';

  @override
  String patientCapturedMoment(String text) {
    return 'Patient saved a moment: \"$text\"';
  }

  @override
  String get patientUploadedPhoto => 'Patient uploaded a new photo memory 📸';

  @override
  String get savedNotesSuccess => 'Today\'s notes saved successfully!';

  @override
  String get failedToSaveNotes => 'Failed to save notes. Try again.';

  @override
  String get checkInHistory => 'Check-In History';

  @override
  String get errorLoadingHistory => 'Error loading history.';

  @override
  String get noHistoryFound => 'No history found. Save your first check-in!';

  @override
  String moodLabel(String mood) {
    return 'Mood: $mood';
  }

  @override
  String wearingLabel(String outfit) {
    return 'Wearing: $outfit';
  }

  @override
  String ateLabel(String meals) {
    return 'Ate: $meals';
  }

  @override
  String get optionalInfoHint =>
      'Everything here is optional. Write whatever you like!';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get whatAreYouWearing => 'What are you wearing today?';

  @override
  String get outfitHint => 'e.g., Blue sweater and brown trousers...';

  @override
  String get whatDidYouEat => 'What did you eat today?';

  @override
  String get mealsHint => 'e.g., Oatmeal for breakfast, chicken soup...';

  @override
  String get saveTodaysStory => 'Save Today\'s Story';

  @override
  String get happy => 'Happy';

  @override
  String get calm => 'Calm';

  @override
  String get tired => 'Tired';

  @override
  String get confused => 'Confused';

  @override
  String get sad => 'Sad';

  @override
  String feeling(String mood) {
    return 'Feeling: $mood';
  }

  @override
  String wearing(String outfit) {
    return 'Wearing: $outfit';
  }

  @override
  String ate(String meals) {
    return 'Ate: $meals';
  }

  @override
  String get completedCheckIn => 'Daily Check-In Completed';

  @override
  String get dailyCheckInTitle => 'Daily Check-In Update ☀️';

  @override
  String patientLoggedStory(String detail) {
    return 'Patient logged today\'s story ($detail)';
  }

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String hrsAgo(int count) {
    return '$count hrs ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get logAVisitor => 'Log a Visitor';

  @override
  String get visitorName => 'Visitor Name';

  @override
  String get visitorNameHint => 'e.g., Sarah';

  @override
  String get relationship => 'Relationship';

  @override
  String get relationshipHint => 'e.g., Daughter / Friend';

  @override
  String get defaultVisitorRole => 'Visitor';

  @override
  String get saveVisit => 'Save Visit';

  @override
  String get logVisit => 'Log Visit';

  @override
  String get noVisitLogsRecordedYet =>
      'No visit logs recorded yet.\nTap + to log a new visitor!';

  @override
  String get newVisitorLoggedTitle => 'New Visitor Logged 👥';

  @override
  String visitorVisitedToday(String name, String relation) {
    return '$name$relation visited today';
  }

  @override
  String get dailyCarePlanner => 'Daily Care Planner';

  @override
  String get taskDescription => 'Task Description';

  @override
  String get noTasksAddedYet => 'No tasks added yet.';

  @override
  String controlDeckTitle(String name) {
    return '$name\'s Control Deck';
  }

  @override
  String get defaultPatientRole => 'Patient';

  @override
  String get todaysProgressTracker => 'Today\'s Progress Tracker';

  @override
  String get noTasksAssignedToday => 'No tasks assigned today';

  @override
  String get allTasksFinished => 'All tasks completed!';

  @override
  String get patientTaskTracking => 'Patient Task Tracking';

  @override
  String get tapCarePlanToAddTasks => 'Tap \'Daily Care Plan\' to add tasks.';

  @override
  String completedTasksSummary(int completed, int total) {
    return '$completed of $total tasks completed.';
  }

  @override
  String get managementModules => 'Management Modules';

  @override
  String get dailyCarePlan => 'Daily Care Plan';

  @override
  String get updateMedsAndTasks => 'Update Medications & Tasks';

  @override
  String get enrolledPeople => 'Enrolled People';

  @override
  String get manageFaceDatabase => 'Manage Face Database';

  @override
  String get oneToOneChat => '1-on-1 Chat';

  @override
  String get textAndVoiceSupport => 'Text & Voice Support';

  @override
  String chatWithPatientTitle(String name) {
    return 'Chat with $name';
  }

  @override
  String get videoCall => 'Video Call';

  @override
  String get connectViaAgora => 'Connect via Agora';

  @override
  String get audioCall => 'Audio Call';

  @override
  String get directVoiceLink => 'Direct Voice Link';

  @override
  String get liveGpsSafety => 'Live GPS Safety';

  @override
  String get geofencingAndAlerts => 'Geofencing & Alerts';

  @override
  String get incomingVideoCall => 'Incoming Video Call';

  @override
  String get incomingAudioCall => 'Incoming Audio Call';

  @override
  String isCalling(String name) {
    return '$name is calling...';
  }

  @override
  String missedCallTitle(String callType) {
    return 'Missed $callType 📞';
  }

  @override
  String get missedCallBody => 'You missed a call. Tap for details.';

  @override
  String get callConnected => 'Connected';

  @override
  String get ringingConnecting => 'Ringing / Connecting...';

  @override
  String get caregiverHub => 'Caregiver Hub';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log Out';

  @override
  String get welcomeToCarePortal => 'Welcome to Care Portal';

  @override
  String get activeMonitoringSession => 'Active Monitoring Session';

  @override
  String get caregiverActions => 'Caregiver Actions';

  @override
  String get registerNewPatient => 'Register New Patient';

  @override
  String get registerNewPatientSubtitle => 'Create a new profile with photos.';

  @override
  String get connectExistingPatient => 'Connect Existing Patient';

  @override
  String get connectExistingPatientSubtitle =>
      'Link with an already registered patient.';

  @override
  String get noPatientActive => 'No active patient';

  @override
  String get unknown => 'Unknown';

  @override
  String patientAgeAndRelation(String age, String relation) {
    return 'Age: $age • $relation';
  }

  @override
  String get launch => 'Launch';

  @override
  String get taskStatusUpdates => 'Task Status Updates:';

  @override
  String get allDone => 'All Done';

  @override
  String pendingTasksCount(int count) {
    return '$count Pending';
  }

  @override
  String activityLog(String activity) {
    return 'Activity Log: $activity';
  }

  @override
  String get noActiveLogUpdates => 'No new activity';

  @override
  String get caregiverSettingsTitle => 'Caregiver Settings';

  @override
  String get sectionAppearanceAccessibility => '🎨 Colors & Theme';

  @override
  String get appAndPatientDarkMode => 'Dark Mode';

  @override
  String get syncsDarkThemeSubtitle =>
      'Syncs dark theme across devices directly';

  @override
  String get appColorTheme => 'App Color Theme';

  @override
  String get selectVisualPaletteSubtitle => 'Select app theme';

  @override
  String get fontTextScale => 'Font Size';

  @override
  String fontScaleSubtitle(String percent) {
    return 'Scale: $percent%';
  }

  @override
  String get fontSizeNormal => 'Normal (100%)';

  @override
  String get fontSizeLarge => 'Large (120%)';

  @override
  String get fontSizeExtraLarge => 'Extra Large (140%)';

  @override
  String get sectionEmergencyContacts => '🚨 Emergency Contacts';

  @override
  String get noEmergencyContacts => 'No emergency contacts added yet.';

  @override
  String get addNewEmergencyContact => 'Add New Contact';

  @override
  String get sectionNotificationsAudio => '🔔 Notifications & Alerts';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Safety perimeter & reminder alerts';

  @override
  String get bypassDoNotDisturb => 'Bypass DND';

  @override
  String get bypassDndSubtitle => 'Allow emergency alerts even in silent mode';

  @override
  String get emergencyRingtone => 'Emergency Ringtone';

  @override
  String get toneChime => 'Chime 🔔';

  @override
  String get toneSiren => 'Siren 🚨';

  @override
  String get tonePulse => 'Pulse 🩺';

  @override
  String get sectionLanguageLocalization => '🌐 Language Selection';

  @override
  String get appLanguageLabel => 'App Language';

  @override
  String get activeLanguageStatus => 'English - Active';

  @override
  String get sectionAboutCompliance => 'ℹ️ App Information';

  @override
  String get aboutAlzheimersEase => 'About Alzheimer\'s Ease';

  @override
  String get aboutAlzheimersEaseSubtitle => 'Key features & guide';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get openingPrivacyPolicySnackbar => 'Opening Privacy Policy page...';

  @override
  String get deleteAccountTitle => 'Delete Account & Data';

  @override
  String get deleteAccountSubtitle =>
      'Account deletion according to Google Play Policy';

  @override
  String get appFooterCredits =>
      'Alzheimer\'s Ease v1.0.0\nDesigned for Patient Safety & Care';

  @override
  String get addEmergencyContactTitle => 'Add Emergency Contact';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'e.g., Dr. Salman';

  @override
  String get enterValidNameError => 'Please enter a valid name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get enterValidPhoneError => 'Please enter a valid phone number';

  @override
  String get relationLabel => 'Relationship';

  @override
  String get relationHint => 'e.g., Doctor, Son, Ambulance';

  @override
  String get saveContactButton => 'Save';

  @override
  String get aboutAppDetailedDescription =>
      'Alzheimer\'s Ease is a comprehensive care platform offering:\n\n• 📍 GPS Safe Zone Monitoring: Instant alerts if patient steps outside bounds.\n• 🚨 Emergency SOS: One-tap direct call to primary emergency contact.\n• 🧠 Face Recognition: Helps patient identify familiar faces.\n• 🖼️ Memory Journal: Store precious moments, notes, and photos.\n• 🔔 Task & Medication Reminders: Timely notifications for daily activities.';

  @override
  String get deleteAccountDialogTitle => 'Delete Account & All Data?';

  @override
  String get deleteAccountDialogContent =>
      'This action will permanently delete all caregiver records, emergency numbers, and tracking data.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAccountRequestSubmittedSnackbar =>
      'Account deletion request submitted.';

  @override
  String get deletePermanentlyButton => 'Delete Permanently';

  @override
  String get deleteMessageTitle => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get clearChatTitle => 'Clear Chat History';

  @override
  String get clearChatConfirm =>
      'Are you sure you want to delete all messages?';

  @override
  String get delete => 'Delete';

  @override
  String get clearAll => 'Clear All';

  @override
  String get noMessagesYet => 'No messages yet. Say hello!';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get newTrustedFaceEnrolledTitle => 'New Trusted Face Registered';

  @override
  String trustedFaceAddedBody(
      String name, String relation, String patientName) {
    return '$name ($relation) was added to $patientName\'s trusted faces.';
  }

  @override
  String get securityUpdateTitle => 'Security Update';

  @override
  String patientDeviceRecognizeBody(String name, String relation) {
    return 'Your device can now recognize $name ($relation).';
  }

  @override
  String get fillAllFieldsAndSelectPhoto =>
      'Please fill in all fields and select a face photo.';

  @override
  String get noClearFaceDetectedError =>
      'No clear face detected in photo. Try again in better lighting.';

  @override
  String get faceRegisteredSuccess => 'Face registered successfully!';

  @override
  String get enrollTrustedFacesTitle => 'Enroll Trusted Faces';

  @override
  String get enrollTrustedFacesSubtitle =>
      'Add family members or caregivers to aid patient recognition.';

  @override
  String get tapToCaptureOrPickPhoto =>
      'Tap to capture or pick photo from gallery';

  @override
  String get enterRelationshipError => 'Enter relationship';

  @override
  String get processAndSaveFaceMatrix => 'Process & Save Face Matrix';

  @override
  String get myDailyHub => 'My Daily Hub';

  @override
  String get exitApp => 'Exit App';

  @override
  String get myTasksToday => 'My Tasks Today';

  @override
  String get allTasksDoneToday => 'All tasks completed today!';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get emergencySos => 'Emergency SOS';

  @override
  String get tapToCallPrimaryEmergencyContact =>
      'Tap to call primary emergency contact';

  @override
  String get guideMeHome => 'Guide Me Home';

  @override
  String get findDirectionsBackHome => 'Find directions back home';

  @override
  String get whoIsThis => 'Who is this?';

  @override
  String get identifyFamilyAndPhotos => 'Identify family members & photos';

  @override
  String get talkToMeChat => 'Talk to Me (Chat)';

  @override
  String get messageYourCaregiver => 'Send a message to your caregiver';

  @override
  String get caregiverChat => 'Caregiver Chat';

  @override
  String get videoCallCaregiver => 'Video Call Caregiver';

  @override
  String get startFaceToFaceCall => 'Start face-to-face video call';

  @override
  String get audioCallCaregiver => 'Audio Call Caregiver';

  @override
  String get startVoiceCall => 'Start voice call';

  @override
  String get memoryDiary => 'Memory Diary';

  @override
  String get viewJournalEntries => 'View diary entries';

  @override
  String callerIsCalling(String callerName) {
    return '$callerName is calling you...';
  }

  @override
  String get errorLaunchingDirections => 'Error finding directions back home';

  @override
  String get registerNewPatientTitle => 'Register New Patient';

  @override
  String get connectExistingPatientTitle => 'Connect Existing Patient';

  @override
  String get savingRecordsUploadingPhotos =>
      'Saving records and uploading photos...';

  @override
  String get registerNewTab => 'Register New';

  @override
  String get linkRegisteredTab => 'Link Existing';

  @override
  String get patientPhotoRequired => 'Patient Photo *';

  @override
  String get yourPhotoCaregiver => 'Your Photo (Caregiver)';

  @override
  String get patientNameLabel => 'Patient Name';

  @override
  String get requiredField => 'This field is required';

  @override
  String get ageLabel => 'Age';

  @override
  String get enterValidAgeError => 'Please enter a valid age';

  @override
  String get relationshipToPatientLabel => 'Relationship to Patient';

  @override
  String get relationshipRequiredHint => 'Required (e.g., Son, Daughter)';

  @override
  String get patientPortalAccessPasswordLabel => 'Patient Portal Password';

  @override
  String get passwordFailHelperText =>
      'Used if fingerprint or biometric authentication fails.';

  @override
  String get passwordLengthError => 'Password must be at least 6 characters';

  @override
  String get setHomeAndSafeZone => 'Set Home Address & Safe Zone';

  @override
  String get useCurrentGpsLocationTooltip => 'Use current GPS location';

  @override
  String get tapMapSetHomeBaseHint =>
      'Tap anywhere on the map to set the patient\'s home base.';

  @override
  String allowedSafeDistanceLabel(int distance) {
    return 'Allowed Safe Distance: $distance m';
  }

  @override
  String get registerPatientAndSaveLocationButton =>
      'Register Patient & Save Location';

  @override
  String get connectToExistingPatientHeader =>
      'Connect to Existing Patient Profile';

  @override
  String get connectPatientDescription =>
      'Enter patient\'s registered name and password to link this caregiver profile.';

  @override
  String get fullRegisteredPatientNameLabel => 'Full Registered Patient Name';

  @override
  String get enterPatientSearchNameError =>
      'Please enter patient name to search';

  @override
  String get validationPasswordLabel => 'Validation Password';

  @override
  String get enterPasswordError => 'Please enter password';

  @override
  String get validateAndLinkProfileButton => 'Validate & Link Profile';

  @override
  String get pickProfilePhotoPrompt => 'Please select patient profile photo';

  @override
  String get patientRegisteredSuccess => 'Patient registered successfully!';

  @override
  String registrationFailedError(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get noPatientFoundNameError => 'No patient found with this name.';

  @override
  String get incorrectPasswordError => 'Incorrect password for this patient.';

  @override
  String successfullyConnectedTo(String name) {
    return 'Successfully connected to $name!';
  }

  @override
  String failedToLinkProfileError(String error) {
    return 'Failed to link profile: $error';
  }

  @override
  String get whoIsThisTitle => 'Who is This?';

  @override
  String get pointCameraInstruction => 'Point camera at a face and press scan';

  @override
  String get noCameraHardwareFound => 'No camera hardware found.';

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String get analyzingFaceStructure => 'Analyzing face structure...';

  @override
  String get noFaceDetected => 'No face detected. Look directly at the camera.';

  @override
  String get noTrustedFacesEnrolled =>
      'No trusted faces have been enrolled by your caregiver yet.';

  @override
  String get matchFound => 'Match Found!';

  @override
  String get unknownPerson =>
      'Unknown Person. This person isn\'t registered in your system.';

  @override
  String analysisError(String error) {
    return 'Analysis error: $error';
  }

  @override
  String yourRelationship(String relationship) {
    return 'Your $relationship';
  }

  @override
  String confidenceScore(String score) {
    return 'Confidence: $score%';
  }

  @override
  String get scanFaceButton => 'Scan Face';

  @override
  String get processingButton => 'Processing...';
}
