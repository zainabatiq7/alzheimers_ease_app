import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Alzheimer\'s Ease'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Care & Connection'**
  String get splashTagline;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Protection & Patient Care Assistant'**
  String get subtitle;

  /// No description provided for @iAmCaregiver.
  ///
  /// In en, this message translates to:
  /// **'I am a Caregiver'**
  String get iAmCaregiver;

  /// No description provided for @iAmPatient.
  ///
  /// In en, this message translates to:
  /// **'I am a Patient'**
  String get iAmPatient;

  /// No description provided for @enterPatientPass.
  ///
  /// In en, this message translates to:
  /// **'Enter Patient Password'**
  String get enterPatientPass;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the password assigned by caregiver'**
  String get passwordHint;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noPatientError.
  ///
  /// In en, this message translates to:
  /// **'No patient is registered on this device! Please register from the caregiver panel.'**
  String get noPatientError;

  /// No description provided for @invalidPassError.
  ///
  /// In en, this message translates to:
  /// **'Invalid password! Please try again.'**
  String get invalidPassError;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Try again.'**
  String get authFailed;

  /// No description provided for @useFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Scan your fingerprint to access your dashboard.'**
  String get useFingerprint;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get pleaseFillAllFields;

  /// No description provided for @loggedInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loggedInSuccess;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @authErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during authentication.'**
  String get authErrorOccurred;

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedErrorOccurred;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get alreadyHaveAccount;

  /// No description provided for @speakToType.
  ///
  /// In en, this message translates to:
  /// **'Speak to type'**
  String get speakToType;

  /// No description provided for @myMemoryDiary.
  ///
  /// In en, this message translates to:
  /// **'My Memory Diary'**
  String get myMemoryDiary;

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @myDayToday.
  ///
  /// In en, this message translates to:
  /// **'My Day Today'**
  String get myDayToday;

  /// No description provided for @myDayTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record how you\'re feeling, what you ate, and what you wore'**
  String get myDayTodaySubtitle;

  /// No description provided for @beautifulMoments.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Moments'**
  String get beautifulMoments;

  /// No description provided for @beautifulMomentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photos, voice notes, and happy memories'**
  String get beautifulMomentsSubtitle;

  /// No description provided for @whoVisitedMe.
  ///
  /// In en, this message translates to:
  /// **'Who Visited Me'**
  String get whoVisitedMe;

  /// No description provided for @whoVisitedMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View recent visits and photos with loved ones'**
  String get whoVisitedMeSubtitle;

  /// No description provided for @addABeautifulMoment.
  ///
  /// In en, this message translates to:
  /// **'Add a Beautiful Moment'**
  String get addABeautifulMoment;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get tapToAddPhoto;

  /// No description provided for @whatMadeThisMomentSpecial.
  ///
  /// In en, this message translates to:
  /// **'What made this moment special?'**
  String get whatMadeThisMomentSpecial;

  /// No description provided for @saveMoment.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveMoment;

  /// No description provided for @addMoment.
  ///
  /// In en, this message translates to:
  /// **'Add Moment'**
  String get addMoment;

  /// No description provided for @noMomentsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No moments recorded yet.\nTap + to save a new memory!'**
  String get noMomentsRecordedYet;

  /// No description provided for @patientNote.
  ///
  /// In en, this message translates to:
  /// **'Patient Note'**
  String get patientNote;

  /// No description provided for @caregiverNote.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Note'**
  String get caregiverNote;

  /// No description provided for @newMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New Memory Saved 📸'**
  String get newMemoryTitle;

  /// No description provided for @patientCapturedMoment.
  ///
  /// In en, this message translates to:
  /// **'Patient saved a moment: \"{text}\"'**
  String patientCapturedMoment(String text);

  /// No description provided for @patientUploadedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Patient uploaded a new photo memory 📸'**
  String get patientUploadedPhoto;

  /// No description provided for @savedNotesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Today\'s notes saved successfully!'**
  String get savedNotesSuccess;

  /// No description provided for @failedToSaveNotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to save notes. Try again.'**
  String get failedToSaveNotes;

  /// No description provided for @checkInHistory.
  ///
  /// In en, this message translates to:
  /// **'Check-In History'**
  String get checkInHistory;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history.'**
  String get errorLoadingHistory;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found. Save your first check-in!'**
  String get noHistoryFound;

  /// No description provided for @moodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood: {mood}'**
  String moodLabel(String mood);

  /// No description provided for @wearingLabel.
  ///
  /// In en, this message translates to:
  /// **'Wearing: {outfit}'**
  String wearingLabel(String outfit);

  /// No description provided for @ateLabel.
  ///
  /// In en, this message translates to:
  /// **'Ate: {meals}'**
  String ateLabel(String meals);

  /// No description provided for @optionalInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Everything here is optional. Write whatever you like!'**
  String get optionalInfoHint;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @whatAreYouWearing.
  ///
  /// In en, this message translates to:
  /// **'What are you wearing today?'**
  String get whatAreYouWearing;

  /// No description provided for @outfitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Blue sweater and brown trousers...'**
  String get outfitHint;

  /// No description provided for @whatDidYouEat.
  ///
  /// In en, this message translates to:
  /// **'What did you eat today?'**
  String get whatDidYouEat;

  /// No description provided for @mealsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Oatmeal for breakfast, chicken soup...'**
  String get mealsHint;

  /// No description provided for @saveTodaysStory.
  ///
  /// In en, this message translates to:
  /// **'Save Today\'s Story'**
  String get saveTodaysStory;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @calm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get calm;

  /// No description provided for @tired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get tired;

  /// No description provided for @confused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get confused;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @feeling.
  ///
  /// In en, this message translates to:
  /// **'Feeling: {mood}'**
  String feeling(String mood);

  /// No description provided for @wearing.
  ///
  /// In en, this message translates to:
  /// **'Wearing: {outfit}'**
  String wearing(String outfit);

  /// No description provided for @ate.
  ///
  /// In en, this message translates to:
  /// **'Ate: {meals}'**
  String ate(String meals);

  /// No description provided for @completedCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-In Completed'**
  String get completedCheckIn;

  /// No description provided for @dailyCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-In Update ☀️'**
  String get dailyCheckInTitle;

  /// No description provided for @patientLoggedStory.
  ///
  /// In en, this message translates to:
  /// **'Patient logged today\'s story ({detail})'**
  String patientLoggedStory(String detail);

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minsAgo(int count);

  /// No description provided for @hrsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hrs ago'**
  String hrsAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @logAVisitor.
  ///
  /// In en, this message translates to:
  /// **'Log a Visitor'**
  String get logAVisitor;

  /// No description provided for @visitorName.
  ///
  /// In en, this message translates to:
  /// **'Visitor Name'**
  String get visitorName;

  /// No description provided for @visitorNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Sarah'**
  String get visitorNameHint;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @relationshipHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Daughter / Friend'**
  String get relationshipHint;

  /// No description provided for @defaultVisitorRole.
  ///
  /// In en, this message translates to:
  /// **'Visitor'**
  String get defaultVisitorRole;

  /// No description provided for @saveVisit.
  ///
  /// In en, this message translates to:
  /// **'Save Visit'**
  String get saveVisit;

  /// No description provided for @logVisit.
  ///
  /// In en, this message translates to:
  /// **'Log Visit'**
  String get logVisit;

  /// No description provided for @noVisitLogsRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No visit logs recorded yet.\nTap + to log a new visitor!'**
  String get noVisitLogsRecordedYet;

  /// No description provided for @newVisitorLoggedTitle.
  ///
  /// In en, this message translates to:
  /// **'New Visitor Logged 👥'**
  String get newVisitorLoggedTitle;

  /// No description provided for @visitorVisitedToday.
  ///
  /// In en, this message translates to:
  /// **'{name}{relation} visited today'**
  String visitorVisitedToday(String name, String relation);

  /// No description provided for @dailyCarePlanner.
  ///
  /// In en, this message translates to:
  /// **'Daily Care Planner'**
  String get dailyCarePlanner;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Task Description'**
  String get taskDescription;

  /// No description provided for @noTasksAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks added yet.'**
  String get noTasksAddedYet;

  /// No description provided for @controlDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Control Deck'**
  String controlDeckTitle(String name);

  /// No description provided for @defaultPatientRole.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get defaultPatientRole;

  /// No description provided for @todaysProgressTracker.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress Tracker'**
  String get todaysProgressTracker;

  /// No description provided for @noTasksAssignedToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned today'**
  String get noTasksAssignedToday;

  /// No description provided for @allTasksFinished.
  ///
  /// In en, this message translates to:
  /// **'All tasks completed!'**
  String get allTasksFinished;

  /// No description provided for @patientTaskTracking.
  ///
  /// In en, this message translates to:
  /// **'Patient Task Tracking'**
  String get patientTaskTracking;

  /// No description provided for @tapCarePlanToAddTasks.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Daily Care Plan\' to add tasks.'**
  String get tapCarePlanToAddTasks;

  /// No description provided for @completedTasksSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks completed.'**
  String completedTasksSummary(int completed, int total);

  /// No description provided for @managementModules.
  ///
  /// In en, this message translates to:
  /// **'Management Modules'**
  String get managementModules;

  /// No description provided for @dailyCarePlan.
  ///
  /// In en, this message translates to:
  /// **'Daily Care Plan'**
  String get dailyCarePlan;

  /// No description provided for @updateMedsAndTasks.
  ///
  /// In en, this message translates to:
  /// **'Update Medications & Tasks'**
  String get updateMedsAndTasks;

  /// No description provided for @enrolledPeople.
  ///
  /// In en, this message translates to:
  /// **'Enrolled People'**
  String get enrolledPeople;

  /// No description provided for @manageFaceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Manage Face Database'**
  String get manageFaceDatabase;

  /// No description provided for @oneToOneChat.
  ///
  /// In en, this message translates to:
  /// **'1-on-1 Chat'**
  String get oneToOneChat;

  /// No description provided for @textAndVoiceSupport.
  ///
  /// In en, this message translates to:
  /// **'Text & Voice Support'**
  String get textAndVoiceSupport;

  /// No description provided for @chatWithPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String chatWithPatientTitle(String name);

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video Call'**
  String get videoCall;

  /// No description provided for @connectViaAgora.
  ///
  /// In en, this message translates to:
  /// **'Connect via Agora'**
  String get connectViaAgora;

  /// No description provided for @audioCall.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get audioCall;

  /// No description provided for @directVoiceLink.
  ///
  /// In en, this message translates to:
  /// **'Direct Voice Link'**
  String get directVoiceLink;

  /// No description provided for @liveGpsSafety.
  ///
  /// In en, this message translates to:
  /// **'Live GPS Safety'**
  String get liveGpsSafety;

  /// No description provided for @geofencingAndAlerts.
  ///
  /// In en, this message translates to:
  /// **'Geofencing & Alerts'**
  String get geofencingAndAlerts;

  /// No description provided for @incomingVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming Video Call'**
  String get incomingVideoCall;

  /// No description provided for @incomingAudioCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming Audio Call'**
  String get incomingAudioCall;

  /// No description provided for @isCalling.
  ///
  /// In en, this message translates to:
  /// **'{name} is calling...'**
  String isCalling(String name);

  /// No description provided for @missedCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed {callType} 📞'**
  String missedCallTitle(String callType);

  /// No description provided for @missedCallBody.
  ///
  /// In en, this message translates to:
  /// **'You missed a call. Tap for details.'**
  String get missedCallBody;

  /// No description provided for @callConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get callConnected;

  /// No description provided for @ringingConnecting.
  ///
  /// In en, this message translates to:
  /// **'Ringing / Connecting...'**
  String get ringingConnecting;

  /// No description provided for @caregiverHub.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Hub'**
  String get caregiverHub;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @welcomeToCarePortal.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Care Portal'**
  String get welcomeToCarePortal;

  /// No description provided for @activeMonitoringSession.
  ///
  /// In en, this message translates to:
  /// **'Active Monitoring Session'**
  String get activeMonitoringSession;

  /// No description provided for @caregiverActions.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Actions'**
  String get caregiverActions;

  /// No description provided for @registerNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Register New Patient'**
  String get registerNewPatient;

  /// No description provided for @registerNewPatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new profile with photos.'**
  String get registerNewPatientSubtitle;

  /// No description provided for @connectExistingPatient.
  ///
  /// In en, this message translates to:
  /// **'Connect Existing Patient'**
  String get connectExistingPatient;

  /// No description provided for @connectExistingPatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link with an already registered patient.'**
  String get connectExistingPatientSubtitle;

  /// No description provided for @noPatientActive.
  ///
  /// In en, this message translates to:
  /// **'No active patient'**
  String get noPatientActive;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @patientAgeAndRelation.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} • {relation}'**
  String patientAgeAndRelation(String age, String relation);

  /// No description provided for @launch.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get launch;

  /// No description provided for @taskStatusUpdates.
  ///
  /// In en, this message translates to:
  /// **'Task Status Updates:'**
  String get taskStatusUpdates;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All Done'**
  String get allDone;

  /// No description provided for @pendingTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String pendingTasksCount(int count);

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log: {activity}'**
  String activityLog(String activity);

  /// No description provided for @noActiveLogUpdates.
  ///
  /// In en, this message translates to:
  /// **'No new activity'**
  String get noActiveLogUpdates;

  /// No description provided for @caregiverSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Settings'**
  String get caregiverSettingsTitle;

  /// No description provided for @sectionAppearanceAccessibility.
  ///
  /// In en, this message translates to:
  /// **'🎨 Colors & Theme'**
  String get sectionAppearanceAccessibility;

  /// No description provided for @appAndPatientDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get appAndPatientDarkMode;

  /// No description provided for @syncsDarkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Syncs dark theme across devices directly'**
  String get syncsDarkThemeSubtitle;

  /// No description provided for @appColorTheme.
  ///
  /// In en, this message translates to:
  /// **'App Color Theme'**
  String get appColorTheme;

  /// No description provided for @selectVisualPaletteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app theme'**
  String get selectVisualPaletteSubtitle;

  /// No description provided for @fontTextScale.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontTextScale;

  /// No description provided for @fontScaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scale: {percent}%'**
  String fontScaleSubtitle(String percent);

  /// No description provided for @fontSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal (100%)'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large (120%)'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large (140%)'**
  String get fontSizeExtraLarge;

  /// No description provided for @sectionEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'🚨 Emergency Contacts'**
  String get sectionEmergencyContacts;

  /// No description provided for @noEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts added yet.'**
  String get noEmergencyContacts;

  /// No description provided for @addNewEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Add New Contact'**
  String get addNewEmergencyContact;

  /// No description provided for @sectionNotificationsAudio.
  ///
  /// In en, this message translates to:
  /// **'🔔 Notifications & Alerts'**
  String get sectionNotificationsAudio;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Safety perimeter & reminder alerts'**
  String get pushNotificationsSubtitle;

  /// No description provided for @bypassDoNotDisturb.
  ///
  /// In en, this message translates to:
  /// **'Bypass DND'**
  String get bypassDoNotDisturb;

  /// No description provided for @bypassDndSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow emergency alerts even in silent mode'**
  String get bypassDndSubtitle;

  /// No description provided for @emergencyRingtone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Ringtone'**
  String get emergencyRingtone;

  /// No description provided for @toneChime.
  ///
  /// In en, this message translates to:
  /// **'Chime 🔔'**
  String get toneChime;

  /// No description provided for @toneSiren.
  ///
  /// In en, this message translates to:
  /// **'Siren 🚨'**
  String get toneSiren;

  /// No description provided for @tonePulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse 🩺'**
  String get tonePulse;

  /// No description provided for @sectionLanguageLocalization.
  ///
  /// In en, this message translates to:
  /// **'🌐 Language Selection'**
  String get sectionLanguageLocalization;

  /// No description provided for @appLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageLabel;

  /// No description provided for @activeLanguageStatus.
  ///
  /// In en, this message translates to:
  /// **'English - Active'**
  String get activeLanguageStatus;

  /// No description provided for @sectionAboutCompliance.
  ///
  /// In en, this message translates to:
  /// **'ℹ️ App Information'**
  String get sectionAboutCompliance;

  /// No description provided for @aboutAlzheimersEase.
  ///
  /// In en, this message translates to:
  /// **'About Alzheimer\'s Ease'**
  String get aboutAlzheimersEase;

  /// No description provided for @aboutAlzheimersEaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key features & guide'**
  String get aboutAlzheimersEaseSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @openingPrivacyPolicySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Opening Privacy Policy page...'**
  String get openingPrivacyPolicySnackbar;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account & Data'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account deletion according to Google Play Policy'**
  String get deleteAccountSubtitle;

  /// No description provided for @appFooterCredits.
  ///
  /// In en, this message translates to:
  /// **'Alzheimer\'s Ease v1.0.0\nDesigned for Patient Safety & Care'**
  String get appFooterCredits;

  /// No description provided for @addEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Emergency Contact'**
  String get addEmergencyContactTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dr. Salman'**
  String get fullNameHint;

  /// No description provided for @enterValidNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name'**
  String get enterValidNameError;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @enterValidPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhoneError;

  /// No description provided for @relationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationLabel;

  /// No description provided for @relationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Doctor, Son, Ambulance'**
  String get relationHint;

  /// No description provided for @saveContactButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveContactButton;

  /// No description provided for @aboutAppDetailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Alzheimer\'s Ease is a comprehensive care platform offering:\n\n• 📍 GPS Safe Zone Monitoring: Instant alerts if patient steps outside bounds.\n• 🚨 Emergency SOS: One-tap direct call to primary emergency contact.\n• 🧠 Face Recognition: Helps patient identify familiar faces.\n• 🖼️ Memory Journal: Store precious moments, notes, and photos.\n• 🔔 Task & Medication Reminders: Timely notifications for daily activities.'**
  String get aboutAppDetailedDescription;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account & All Data?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete all caregiver records, emergency numbers, and tracking data.'**
  String get deleteAccountDialogContent;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteAccountRequestSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account deletion request submitted.'**
  String get deleteAccountRequestSubmittedSnackbar;

  /// No description provided for @deletePermanentlyButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanentlyButton;

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessageTitle;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @clearChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatTitle;

  /// No description provided for @clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages?'**
  String get clearChatConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get noMessagesYet;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @newTrustedFaceEnrolledTitle.
  ///
  /// In en, this message translates to:
  /// **'New Trusted Face Registered'**
  String get newTrustedFaceEnrolledTitle;

  /// No description provided for @trustedFaceAddedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} ({relation}) was added to {patientName}\'s trusted faces.'**
  String trustedFaceAddedBody(String name, String relation, String patientName);

  /// No description provided for @securityUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Update'**
  String get securityUpdateTitle;

  /// No description provided for @patientDeviceRecognizeBody.
  ///
  /// In en, this message translates to:
  /// **'Your device can now recognize {name} ({relation}).'**
  String patientDeviceRecognizeBody(String name, String relation);

  /// No description provided for @fillAllFieldsAndSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields and select a face photo.'**
  String get fillAllFieldsAndSelectPhoto;

  /// No description provided for @noClearFaceDetectedError.
  ///
  /// In en, this message translates to:
  /// **'No clear face detected in photo. Try again in better lighting.'**
  String get noClearFaceDetectedError;

  /// No description provided for @faceRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Face registered successfully!'**
  String get faceRegisteredSuccess;

  /// No description provided for @enrollTrustedFacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Enroll Trusted Faces'**
  String get enrollTrustedFacesTitle;

  /// No description provided for @enrollTrustedFacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add family members or caregivers to aid patient recognition.'**
  String get enrollTrustedFacesSubtitle;

  /// No description provided for @tapToCaptureOrPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture or pick photo from gallery'**
  String get tapToCaptureOrPickPhoto;

  /// No description provided for @enterRelationshipError.
  ///
  /// In en, this message translates to:
  /// **'Enter relationship'**
  String get enterRelationshipError;

  /// No description provided for @processAndSaveFaceMatrix.
  ///
  /// In en, this message translates to:
  /// **'Process & Save Face Matrix'**
  String get processAndSaveFaceMatrix;

  /// No description provided for @myDailyHub.
  ///
  /// In en, this message translates to:
  /// **'My Daily Hub'**
  String get myDailyHub;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @myTasksToday.
  ///
  /// In en, this message translates to:
  /// **'My Tasks Today'**
  String get myTasksToday;

  /// No description provided for @allTasksDoneToday.
  ///
  /// In en, this message translates to:
  /// **'All tasks completed today!'**
  String get allTasksDoneToday;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @emergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get emergencySos;

  /// No description provided for @tapToCallPrimaryEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Tap to call primary emergency contact'**
  String get tapToCallPrimaryEmergencyContact;

  /// No description provided for @guideMeHome.
  ///
  /// In en, this message translates to:
  /// **'Guide Me Home'**
  String get guideMeHome;

  /// No description provided for @findDirectionsBackHome.
  ///
  /// In en, this message translates to:
  /// **'Find directions back home'**
  String get findDirectionsBackHome;

  /// No description provided for @whoIsThis.
  ///
  /// In en, this message translates to:
  /// **'Who is this?'**
  String get whoIsThis;

  /// No description provided for @identifyFamilyAndPhotos.
  ///
  /// In en, this message translates to:
  /// **'Identify family members & photos'**
  String get identifyFamilyAndPhotos;

  /// No description provided for @talkToMeChat.
  ///
  /// In en, this message translates to:
  /// **'Talk to Me (Chat)'**
  String get talkToMeChat;

  /// No description provided for @messageYourCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Send a message to your caregiver'**
  String get messageYourCaregiver;

  /// No description provided for @caregiverChat.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Chat'**
  String get caregiverChat;

  /// No description provided for @videoCallCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Video Call Caregiver'**
  String get videoCallCaregiver;

  /// No description provided for @startFaceToFaceCall.
  ///
  /// In en, this message translates to:
  /// **'Start face-to-face video call'**
  String get startFaceToFaceCall;

  /// No description provided for @audioCallCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Audio Call Caregiver'**
  String get audioCallCaregiver;

  /// No description provided for @startVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Start voice call'**
  String get startVoiceCall;

  /// No description provided for @memoryDiary.
  ///
  /// In en, this message translates to:
  /// **'Memory Diary'**
  String get memoryDiary;

  /// No description provided for @viewJournalEntries.
  ///
  /// In en, this message translates to:
  /// **'View diary entries'**
  String get viewJournalEntries;

  /// No description provided for @callerIsCalling.
  ///
  /// In en, this message translates to:
  /// **'{callerName} is calling you...'**
  String callerIsCalling(String callerName);

  /// No description provided for @errorLaunchingDirections.
  ///
  /// In en, this message translates to:
  /// **'Error finding directions back home'**
  String get errorLaunchingDirections;

  /// No description provided for @registerNewPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Register New Patient'**
  String get registerNewPatientTitle;

  /// No description provided for @connectExistingPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Existing Patient'**
  String get connectExistingPatientTitle;

  /// No description provided for @savingRecordsUploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Saving records and uploading photos...'**
  String get savingRecordsUploadingPhotos;

  /// No description provided for @registerNewTab.
  ///
  /// In en, this message translates to:
  /// **'Register New'**
  String get registerNewTab;

  /// No description provided for @linkRegisteredTab.
  ///
  /// In en, this message translates to:
  /// **'Link Existing'**
  String get linkRegisteredTab;

  /// No description provided for @patientPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Patient Photo *'**
  String get patientPhotoRequired;

  /// No description provided for @yourPhotoCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Your Photo (Caregiver)'**
  String get yourPhotoCaregiver;

  /// No description provided for @patientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientNameLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @enterValidAgeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get enterValidAgeError;

  /// No description provided for @relationshipToPatientLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship to Patient'**
  String get relationshipToPatientLabel;

  /// No description provided for @relationshipRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Required (e.g., Son, Daughter)'**
  String get relationshipRequiredHint;

  /// No description provided for @patientPortalAccessPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient Portal Password'**
  String get patientPortalAccessPasswordLabel;

  /// No description provided for @passwordFailHelperText.
  ///
  /// In en, this message translates to:
  /// **'Used if fingerprint or biometric authentication fails.'**
  String get passwordFailHelperText;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @setHomeAndSafeZone.
  ///
  /// In en, this message translates to:
  /// **'Set Home Address & Safe Zone'**
  String get setHomeAndSafeZone;

  /// No description provided for @useCurrentGpsLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use current GPS location'**
  String get useCurrentGpsLocationTooltip;

  /// No description provided for @tapMapSetHomeBaseHint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere on the map to set the patient\'s home base.'**
  String get tapMapSetHomeBaseHint;

  /// No description provided for @allowedSafeDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowed Safe Distance: {distance} m'**
  String allowedSafeDistanceLabel(int distance);

  /// No description provided for @registerPatientAndSaveLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Register Patient & Save Location'**
  String get registerPatientAndSaveLocationButton;

  /// No description provided for @connectToExistingPatientHeader.
  ///
  /// In en, this message translates to:
  /// **'Connect to Existing Patient Profile'**
  String get connectToExistingPatientHeader;

  /// No description provided for @connectPatientDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter patient\'s registered name and password to link this caregiver profile.'**
  String get connectPatientDescription;

  /// No description provided for @fullRegisteredPatientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Registered Patient Name'**
  String get fullRegisteredPatientNameLabel;

  /// No description provided for @enterPatientSearchNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient name to search'**
  String get enterPatientSearchNameError;

  /// No description provided for @validationPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Validation Password'**
  String get validationPasswordLabel;

  /// No description provided for @enterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPasswordError;

  /// No description provided for @validateAndLinkProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Validate & Link Profile'**
  String get validateAndLinkProfileButton;

  /// No description provided for @pickProfilePhotoPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select patient profile photo'**
  String get pickProfilePhotoPrompt;

  /// No description provided for @patientRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient registered successfully!'**
  String get patientRegisteredSuccess;

  /// No description provided for @registrationFailedError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailedError(String error);

  /// No description provided for @noPatientFoundNameError.
  ///
  /// In en, this message translates to:
  /// **'No patient found with this name.'**
  String get noPatientFoundNameError;

  /// No description provided for @incorrectPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password for this patient.'**
  String get incorrectPasswordError;

  /// No description provided for @successfullyConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Successfully connected to {name}!'**
  String successfullyConnectedTo(String name);

  /// No description provided for @failedToLinkProfileError.
  ///
  /// In en, this message translates to:
  /// **'Failed to link profile: {error}'**
  String failedToLinkProfileError(String error);

  /// App bar title for the facial recognition screen
  ///
  /// In en, this message translates to:
  /// **'Who is This?'**
  String get whoIsThisTitle;

  /// No description provided for @pointCameraInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point camera at a face and press scan'**
  String get pointCameraInstruction;

  /// No description provided for @noCameraHardwareFound.
  ///
  /// In en, this message translates to:
  /// **'No camera hardware found.'**
  String get noCameraHardwareFound;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// No description provided for @analyzingFaceStructure.
  ///
  /// In en, this message translates to:
  /// **'Analyzing face structure...'**
  String get analyzingFaceStructure;

  /// No description provided for @noFaceDetected.
  ///
  /// In en, this message translates to:
  /// **'No face detected. Look directly at the camera.'**
  String get noFaceDetected;

  /// No description provided for @noTrustedFacesEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No trusted faces have been enrolled by your caregiver yet.'**
  String get noTrustedFacesEnrolled;

  /// No description provided for @matchFound.
  ///
  /// In en, this message translates to:
  /// **'Match Found!'**
  String get matchFound;

  /// No description provided for @unknownPerson.
  ///
  /// In en, this message translates to:
  /// **'Unknown Person. This person isn\'t registered in your system.'**
  String get unknownPerson;

  /// No description provided for @analysisError.
  ///
  /// In en, this message translates to:
  /// **'Analysis error: {error}'**
  String analysisError(String error);

  /// No description provided for @yourRelationship.
  ///
  /// In en, this message translates to:
  /// **'Your {relationship}'**
  String yourRelationship(String relationship);

  /// No description provided for @confidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {score}%'**
  String confidenceScore(String score);

  /// No description provided for @scanFaceButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Face'**
  String get scanFaceButton;

  /// No description provided for @processingButton.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
