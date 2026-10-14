// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'الزائمر ایز';

  @override
  String get splashTagline => 'دیکھ بھال اور تعلق';

  @override
  String get subtitle => 'یاداشت کی حفاظت اور مریض کی دیکھ بھال میں معاون';

  @override
  String get iAmCaregiver => 'میں دیکھ بھال کرنے والا ہوں';

  @override
  String get iAmPatient => 'میں مریض ہوں';

  @override
  String get enterPatientPass => 'مریض کا پاس ورڈ درج کریں';

  @override
  String get passwordHint => 'دیکھ بھال کرنے والے کا دیا ہوا پاس ورڈ درج کریں';

  @override
  String get login => 'لاگ ان کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get noPatientError =>
      'اس ڈیوائس پر کوئی مریض رجسٹرڈ نہیں ہے! برائے مہربانی کیئرگیور پینل سے رجسٹر کریں۔';

  @override
  String get invalidPassError => 'غلط پاس ورڈ! دوبارہ کوشش کریں۔';

  @override
  String get authFailed => 'تصدیق ناکام ہو گئی۔ دوبارہ کوشش کریں۔';

  @override
  String get useFingerprint =>
      'اپنے ڈیش بورڈ میں داخل ہونے کے لیے اپنا فنگر پرنٹ اسکین کریں۔';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get pleaseFillAllFields => 'برائے مہربانی تمام خانوں کو پر کریں۔';

  @override
  String get loggedInSuccess => 'کامیابی کے ساتھ لاگ ان ہو گئے!';

  @override
  String get accountCreatedSuccess => 'اکاؤنٹ کامیابی سے بن گیا!';

  @override
  String get authErrorOccurred => 'تصدیق کے دوران غلطی پیش آئی۔';

  @override
  String get unexpectedErrorOccurred => 'غیر متوقع غلطی پیش آئی۔';

  @override
  String get emailAddress => 'ای میل ایڈریس';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get logIn => 'لاگ ان';

  @override
  String get signUp => 'سائن اپ';

  @override
  String get dontHaveAccount => 'اکاؤنٹ نہیں ہے؟ سائن اپ کریں';

  @override
  String get alreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟ لاگ ان کریں';

  @override
  String get speakToType => 'ٹائپ کرنے کے لیے بولیں';

  @override
  String get myMemoryDiary => 'میری یادداشت ڈائری';

  @override
  String get whatWouldYouLikeToDo => 'آپ کیا کرنا چاہیں گے؟';

  @override
  String get myDayToday => 'میرا آج کا دن';

  @override
  String get myDayTodaySubtitle =>
      'ریکارڈ کریں آپ کیسا محسوس کر رہے ہیں، کیا کھایا اور کیا پہنا';

  @override
  String get beautifulMoments => 'خوبصورت لمحات';

  @override
  String get beautifulMomentsSubtitle => 'تصاویر، وائس نوٹس اور خوشگوار یادیں';

  @override
  String get whoVisitedMe => 'مجھ سے کون ملنے آیا';

  @override
  String get whoVisitedMeSubtitle =>
      'پیاروں کے ساتھ حالیہ ملاقاتیں اور تصاویر دیکھیں';

  @override
  String get addABeautifulMoment => 'ایک خوبصورت لمحات شامل کریں';

  @override
  String get tapToAddPhoto => 'تصویر شامل کرنے کے لیے ٹیپ کریں';

  @override
  String get whatMadeThisMomentSpecial => 'کس چیز نے اس لمحے کو خاص بنایا؟';

  @override
  String get saveMoment => 'محفوظ کریں';

  @override
  String get addMoment => 'لمحہ شامل کریں';

  @override
  String get noMomentsRecordedYet =>
      'ابھی تک کوئی لمحات محفوظ نہیں کیے گئے۔\nنئی یاد محفوظ کرنے کے لیے + ٹیپ کریں!';

  @override
  String get patientNote => 'مریض کا نوٹ';

  @override
  String get caregiverNote => 'کیئرگیور کا نوٹ';

  @override
  String get newMemoryTitle => 'نئی یاد درج کر لی گئی 📸';

  @override
  String patientCapturedMoment(String text) {
    return 'مریض نے ایک لمحہ محفوظ کیا: \"$text\"';
  }

  @override
  String get patientUploadedPhoto =>
      'مریض نے ایک نئی تصویر کی یاد اپ لوڈ کی 📸';

  @override
  String get savedNotesSuccess => 'آج کے نوٹس محفوظ کر لیے گئے!';

  @override
  String get failedToSaveNotes =>
      'نوٹس محفوظ کرنے میں ناکامی۔ دوبارہ کوشش کریں۔';

  @override
  String get checkInHistory => 'چیک ان ہسٹری';

  @override
  String get errorLoadingHistory => 'ہسٹری لوڈ کرنے میں غلطی۔';

  @override
  String get noHistoryFound =>
      'کوئی ہسٹری نہیں ملی۔ اپنا پہلا چیک ان محفوظ کریں!';

  @override
  String moodLabel(String mood) {
    return 'موڈ: $mood';
  }

  @override
  String wearingLabel(String outfit) {
    return 'پہنا ہوا: $outfit';
  }

  @override
  String ateLabel(String meals) {
    return 'کھایا: $meals';
  }

  @override
  String get optionalInfoHint => 'یہاں ہر چیز اختیاری ہے۔ جو چاہیں لکھیں!';

  @override
  String get howAreYouFeeling => 'آپ کیسا محسوس کر رہے ہیں؟';

  @override
  String get whatAreYouWearing => 'آج آپ نے کیا پہنا ہوا ہے؟';

  @override
  String get outfitHint => 'مثلاً نیلا سویٹر اور بھوری پتلون...';

  @override
  String get whatDidYouEat => 'آج آپ نے کیا کھایا؟';

  @override
  String get mealsHint => 'مثلاً ناشتے میں دلیہ، چکن سوپ...';

  @override
  String get saveTodaysStory => 'آج کی کہانی محفوظ کریں';

  @override
  String get happy => 'خوش';

  @override
  String get calm => 'پرپرسکون';

  @override
  String get tired => 'تھکا ہوا';

  @override
  String get confused => 'الجھن میں';

  @override
  String get sad => 'اداس';

  @override
  String feeling(String mood) {
    return 'احساس: $mood';
  }

  @override
  String wearing(String outfit) {
    return 'پہنا ہوا: $outfit';
  }

  @override
  String ate(String meals) {
    return 'کھایا: $meals';
  }

  @override
  String get completedCheckIn => 'روزانہ چیک ان مکمل ہوا';

  @override
  String get dailyCheckInTitle => 'روزانہ چیک ان کی آپ ڈیٹ ☀️';

  @override
  String patientLoggedStory(String detail) {
    return 'مریض نے آج کی کہانی کا اندراج کیا ($detail)';
  }

  @override
  String minsAgo(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String hrsAgo(int count) {
    return '$count گھنٹے پہلے';
  }

  @override
  String daysAgo(int count) {
    return '$count دن پہلے';
  }

  @override
  String get logAVisitor => 'ملاقاتی کا اندراج کریں';

  @override
  String get visitorName => 'ملاقاتی کا نام';

  @override
  String get visitorNameHint => 'مثلاً سارہ';

  @override
  String get relationship => 'رشتہ / تعلق';

  @override
  String get relationshipHint => 'مثلاً بیٹی / دوست';

  @override
  String get defaultVisitorRole => 'ملاقاتی';

  @override
  String get saveVisit => 'ملاقات محفوظ کریں';

  @override
  String get logVisit => 'ملاقات درج کریں';

  @override
  String get noVisitLogsRecordedYet =>
      'ابھی تک کوئی ملاقات نہیں لکھی گئی۔\nنیا ملاقاتی درج کرنے کے لیے + ٹیپ کریں!';

  @override
  String get newVisitorLoggedTitle => 'نیا ملاقاتی درج ہو گیا 👥';

  @override
  String visitorVisitedToday(String name, String relation) {
    return '$name$relation نے آج ملاقات کی';
  }

  @override
  String get dailyCarePlanner => 'روزانہ کی دیکھ بھال کا منصوبہ';

  @override
  String get taskDescription => 'کام کی تفصیل';

  @override
  String get noTasksAddedYet => 'ابھی تک کوئی کام شامل نہیں کیا گیا۔';

  @override
  String controlDeckTitle(String name) {
    return '$name کا کنٹرول ڈیک';
  }

  @override
  String get defaultPatientRole => 'مریض';

  @override
  String get todaysProgressTracker => 'آج کی پیشرفت کا ٹریکر';

  @override
  String get noTasksAssignedToday => 'آج کوئی کام تفویض نہیں کیا گیا';

  @override
  String get allTasksFinished => 'تمام کام مکمل ہو گئے!';

  @override
  String get patientTaskTracking => 'مریض کے کاموں کی نگرانی';

  @override
  String get tapCarePlanToAddTasks =>
      'کام شامل کرنے کے لیے \'روزانہ دیکھ بھال کا منصوبہ\' پر ٹیپ کریں۔';

  @override
  String completedTasksSummary(int completed, int total) {
    return 'کل $total میں سے $completed کام مکمل ہوئے۔';
  }

  @override
  String get managementModules => 'انتظامی ماڈیولز';

  @override
  String get dailyCarePlan => 'روزانہ دیکھ بھال کا منصوبہ';

  @override
  String get updateMedsAndTasks => 'ادویات اور کاموں کی آپ ڈیٹ';

  @override
  String get enrolledPeople => 'شامل کیے گئے افراد';

  @override
  String get manageFaceDatabase => 'چہروں کے ڈیٹابیس کا انتظام';

  @override
  String get oneToOneChat => 'باہمی بات چیت';

  @override
  String get textAndVoiceSupport => 'ٹیکسٹ اور وائس کی سہولت';

  @override
  String chatWithPatientTitle(String name) {
    return '$name کے ساتھ بات چیت';
  }

  @override
  String get videoCall => 'ویڈیو کال';

  @override
  String get connectViaAgora => 'ایگورا کے ذریعے رابطہ کریں';

  @override
  String get audioCall => 'آڈیو کال';

  @override
  String get directVoiceLink => 'براہ راست وائس رابطہ';

  @override
  String get liveGpsSafety => 'لائیو جی پی ایس تحفظ';

  @override
  String get geofencingAndAlerts => 'جیوفینسنگ اور الرٹس';

  @override
  String get incomingVideoCall => 'آمدہ ویڈیو کال';

  @override
  String get incomingAudioCall => 'آمدہ آڈیو کال';

  @override
  String isCalling(String name) {
    return '$name کال کر رہے ہیں...';
  }

  @override
  String missedCallTitle(String callType) {
    return 'مسڈ $callType 📞';
  }

  @override
  String get missedCallBody =>
      'آپ کی ایک کال مس ہو گئی۔ تفاصیل کے لیے ٹیپ کریں۔';

  @override
  String get callConnected => 'رابطہ ہو گیا';

  @override
  String get ringingConnecting => 'کال جا رہی ہے / رابطہ ہو رہا ہے...';

  @override
  String get caregiverHub => 'کیئرگیور ہب';

  @override
  String get settings => 'سیٹنگز';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get welcomeToCarePortal => 'آپ کے کیئر پورٹل میں خوش آمدید';

  @override
  String get activeMonitoringSession => 'فعال مانیٹرنگ سیشن';

  @override
  String get caregiverActions => 'کیئرگیور کے اقدامات';

  @override
  String get registerNewPatient => 'نیا مریض رجسٹر کریں';

  @override
  String get registerNewPatientSubtitle =>
      'تصاویر کے ساتھ ایک نیا پروفائل بنائیں۔';

  @override
  String get connectExistingPatient => 'موجودہ مریض کو منسلک کریں';

  @override
  String get connectExistingPatientSubtitle =>
      'پہلے سے رجسٹرڈ مریض کے ساتھ لنک بنائیں۔';

  @override
  String get noPatientActive => 'کوئی مریض فعال نہیں ہے';

  @override
  String get unknown => 'نامعلوم';

  @override
  String patientAgeAndRelation(String age, String relation) {
    return 'عمر: $age • $relation';
  }

  @override
  String get launch => 'کھولیں';

  @override
  String get taskStatusUpdates => 'کام کی صورتحال کی آپ ڈیٹ:';

  @override
  String get allDone => 'تمام مکمل';

  @override
  String pendingTasksCount(int count) {
    return '$count باقی ہیں';
  }

  @override
  String activityLog(String activity) {
    return 'سرگرمی کی لاگ: $activity';
  }

  @override
  String get noActiveLogUpdates => 'کوئی نئی سرگرمی نہیں ہے';

  @override
  String get caregiverSettingsTitle => 'دیکھ بھال کرنے والے کی ترتیبات';

  @override
  String get sectionAppearanceAccessibility => '🎨 رنگ اور تھیم';

  @override
  String get appAndPatientDarkMode => 'ڈارک موڈ (Dark Mode)';

  @override
  String get syncsDarkThemeSubtitle =>
      'تمام ڈیوائسز پر ڈارک تھیم براہ راست ملاتی ہے';

  @override
  String get appColorTheme => 'ایپ کا رنگ';

  @override
  String get selectVisualPaletteSubtitle => 'تھیم کا انتخاب کریں';

  @override
  String get fontTextScale => 'فونٹ کا سائز';

  @override
  String fontScaleSubtitle(String percent) {
    return 'سائز: $percent%';
  }

  @override
  String get fontSizeNormal => 'عام (100%)';

  @override
  String get fontSizeLarge => 'بڑا (120%)';

  @override
  String get fontSizeExtraLarge => 'بہت بڑا (140%)';

  @override
  String get sectionEmergencyContacts => '🚨 ہنگامی رابطے';

  @override
  String get noEmergencyContacts => 'کوئی ہنگامی رابطہ موجود نہیں ہے۔';

  @override
  String get addNewEmergencyContact => 'نیا رابطہ شامل کریں';

  @override
  String get sectionNotificationsAudio => '🔔 نوٹیفکیشن اور الرٹس';

  @override
  String get pushNotifications => 'پش نوٹیفکیشنز';

  @override
  String get pushNotificationsSubtitle => 'حفاظتی حد اور یاد دہانی کے انتباہات';

  @override
  String get bypassDoNotDisturb => 'ڈی این ڈی بائی پاس';

  @override
  String get bypassDndSubtitle => 'سائلنٹ موڈ پر بھی ہنگامی الرٹس کی اجازت دیں';

  @override
  String get emergencyRingtone => 'ایمرجنسی رنگ ٹون';

  @override
  String get toneChime => 'چائم 🔔';

  @override
  String get toneSiren => 'سائرن 🚨';

  @override
  String get tonePulse => 'پلس 🩺';

  @override
  String get sectionLanguageLocalization => '🌐 زبان کا انتخاب';

  @override
  String get appLanguageLabel => 'ایپ کی زبان';

  @override
  String get activeLanguageStatus => 'اردو - فعال ہے';

  @override
  String get sectionAboutCompliance => 'ℹ️ ایپ کی معلومات';

  @override
  String get aboutAlzheimersEase => 'الزائمرز ایز کے بارے میں';

  @override
  String get aboutAlzheimersEaseSubtitle => 'اہم خصوصیات اور رہنمائی';

  @override
  String get privacyPolicyTitle => 'پرائیویسی پالیسی';

  @override
  String get openingPrivacyPolicySnackbar =>
      'پرائیویسی پالیسی کا صفحہ کھولا جا رہا ہے...';

  @override
  String get deleteAccountTitle => 'اکاؤنٹ اور ڈیٹا ڈلیٹ کریں';

  @override
  String get deleteAccountSubtitle =>
      'گوگل پلے پالیسی کے مطابق اکاؤنٹ کا خاتمہ';

  @override
  String get appFooterCredits =>
      'الزائمرز ایز v1.0.0\nمریض کی حفاظت اور دیکھ بھال کے لیے تیار کردہ';

  @override
  String get addEmergencyContactTitle => 'ہنگامی رابطہ شامل کریں';

  @override
  String get fullNameLabel => 'پورا نام';

  @override
  String get fullNameHint => 'مثلاً: ڈاکٹر سلمان';

  @override
  String get enterValidNameError => 'براہ کرم درست نام درج کریں';

  @override
  String get phoneNumberLabel => 'فون نمبر';

  @override
  String get enterValidPhoneError => 'براہ کرم درست فون نمبر درج کریں';

  @override
  String get relationLabel => 'رشتہ';

  @override
  String get relationHint => 'مثلاً: ڈاکٹر، بیٹا، ایمبولینس';

  @override
  String get saveContactButton => 'محفوظ کریں';

  @override
  String get aboutAppDetailedDescription =>
      'الزائمرز ایز ایک مکمل معاون نظام ہے جس کی اہم خصوصیات درج ذیل ہیں:\n\n• 📍 جی پی ایس سیف زون مانیٹرنگ: مریض کے مقررہ حد سے باہر نکلنے پر فوری اطلاع۔\n• 🚨 ایمرجنسی ایس او ایس: بٹن دبانے پر پہلے محفوظ ہنگامی نمبر پر براہ راست کال۔\n• 🧠 فیس ریکگنیشن: معروف چہروں کو پہچاننے میں مریض کی مدد۔\n• 🖼️ خوبصورت لمحات (میموری جرنل): یادگار تصاویر اور تحریریں محفوظ کرنے کی جگہ۔\n• 🔔 ادویات اور کاموں کی یاد دہانی: روزمرہ کاموں کے بروقت نوٹیفکیشنز۔';

  @override
  String get deleteAccountDialogTitle => 'اکاؤنٹ اور تمام ڈیٹا ڈلیٹ کریں؟';

  @override
  String get deleteAccountDialogContent =>
      'یہ عمل تمام کیئر گیور ریکارڈز، ایمرجنسی نمبرز اور ٹریکنگ ڈیٹا کو مستقل طور پر ختم کر دے گا۔';

  @override
  String get cancelButton => 'منسوخ کریں';

  @override
  String get deleteAccountRequestSubmittedSnackbar =>
      'اکاؤنٹ ڈلیٹ کرنے کی درخواست بھیج دی گئی ہے۔';

  @override
  String get deletePermanentlyButton => 'مستقل ختم کریں';

  @override
  String get deleteMessageTitle => 'پیغام حذف کریں';

  @override
  String get deleteMessageConfirm =>
      'کیا آپ واقعی اس پیغام کو حذف کرنا چاہتے ہیں؟';

  @override
  String get clearChatTitle => 'چیٹ ہسٹری صاف کریں';

  @override
  String get clearChatConfirm =>
      'کیا آپ واقعی تمام پیغامات حذف کرنا چاہتے ہیں؟';

  @override
  String get delete => 'حذف کریں';

  @override
  String get clearAll => 'تمام حذف کریں';

  @override
  String get noMessagesYet => 'ابھی کوئی پیغام نہیں ہے۔ سلام کریں!';

  @override
  String get typeAMessage => 'پیغام ٹائپ کریں...';

  @override
  String get pickFromGallery => 'گیلری سے منتخب کریں';

  @override
  String get takeAPhoto => 'تصویر لیں';

  @override
  String get newTrustedFaceEnrolledTitle => 'نیا قابل اعتماد چہرہ رجسٹر ہوا';

  @override
  String trustedFaceAddedBody(
      String name, String relation, String patientName) {
    return '$name ($relation) کو $patientName کے قابل اعتماد چہروں میں شامل کر دیا گیا۔';
  }

  @override
  String get securityUpdateTitle => 'سیکیورٹی آپ ڈیٹ';

  @override
  String patientDeviceRecognizeBody(String name, String relation) {
    return 'اب آپ کی ڈیوائس $name ($relation) کو پہچان سکتی ہے۔';
  }

  @override
  String get fillAllFieldsAndSelectPhoto =>
      'براہ کرم تمام خانے پر کریں اور چہرے کی تصویر منتخب کریں۔';

  @override
  String get noClearFaceDetectedError =>
      'تصویر میں کوئی واضح چہرہ نہیں ملا۔ بہتر روشنی میں دوبارہ کوشش کریں۔';

  @override
  String get faceRegisteredSuccess => 'چہرہ کامیابی سے رجسٹر ہو گیا!';

  @override
  String get enrollTrustedFacesTitle => 'قابل اعتماد چہرے شامل کریں';

  @override
  String get enrollTrustedFacesSubtitle =>
      'مریض کی پہچان کے لیے خاندان کے فرد یا دیکھ بھال کرنے والے کا چہرہ شامل کریں۔';

  @override
  String get tapToCaptureOrPickPhoto =>
      'تصویر لینے یا گیلری سے منتخب کرنے کے لیے ٹیپ کریں';

  @override
  String get enterRelationshipError => 'رشتہ درج کریں';

  @override
  String get processAndSaveFaceMatrix => 'چہرہ پروسیس کریں اور محفوظ کریں';

  @override
  String get myDailyHub => 'میرا روزانہ کا ہب';

  @override
  String get exitApp => 'ایپ بند کریں';

  @override
  String get myTasksToday => 'آج کے میرے کام';

  @override
  String get allTasksDoneToday => 'آج کے تمام کام مکمل ہو گئے!';

  @override
  String get quickActions => 'فوری اقدامات';

  @override
  String get emergencySos => 'ایمرجنسی ایس او ایس';

  @override
  String get tapToCallPrimaryEmergencyContact =>
      'بنیادی ہنگامی رابطے کو کال کرنے کے لیے ٹیپ کریں';

  @override
  String get guideMeHome => 'مجھے گھر کا راستہ دکھائیں';

  @override
  String get findDirectionsBackHome => 'واپس گھر کا راستہ تلاش کریں';

  @override
  String get whoIsThis => 'یہ کون ہے؟';

  @override
  String get identifyFamilyAndPhotos => 'خاندان اور تصاویر کی شناخت کریں';

  @override
  String get talkToMeChat => 'مجھ سے بات کریں (چیٹ)';

  @override
  String get messageYourCaregiver => 'اپنے کیئرگیور کو پیغام بھیجیں';

  @override
  String get caregiverChat => 'کیئرگیور چیٹ';

  @override
  String get videoCallCaregiver => 'کیئرگیور کو ویڈیو کال کریں';

  @override
  String get startFaceToFaceCall => 'آمنے سامنے کال شروع کریں';

  @override
  String get audioCallCaregiver => 'کیئرگیور کو آڈیو کال کریں';

  @override
  String get startVoiceCall => 'وائس کال شروع کریں';

  @override
  String get memoryDiary => 'یادداشت ڈائری';

  @override
  String get viewJournalEntries => 'ڈائری کے اندراجات دیکھیں';

  @override
  String callerIsCalling(String callerName) {
    return '$callerName آپ کو کال کر رہے ہیں...';
  }

  @override
  String get errorLaunchingDirections => 'راستہ تلاش کرنے میں غلطی پیش آئی';

  @override
  String get registerNewPatientTitle => 'نیا مریض رجسٹر کریں';

  @override
  String get connectExistingPatientTitle => 'موجودہ مریض کو منسلک کریں';

  @override
  String get savingRecordsUploadingPhotos =>
      'ریکارڈ محفوظ ہو رہا ہے اور تصاویر اپ لوڈ ہو رہی ہیں...';

  @override
  String get registerNewTab => 'نیا رجسٹر کریں';

  @override
  String get linkRegisteredTab => 'موجودہ سے لنک کریں';

  @override
  String get patientPhotoRequired => 'مریض کی تصویر *';

  @override
  String get yourPhotoCaregiver => 'آپ کی تصویر (کیئرگیور)';

  @override
  String get patientNameLabel => 'مریض کا نام';

  @override
  String get requiredField => 'یہ خانہ پر کرنا ضروری ہے';

  @override
  String get ageLabel => 'عمر';

  @override
  String get enterValidAgeError => 'برائے مہربانی درست عمر درج کریں';

  @override
  String get relationshipToPatientLabel => 'مریض سے رشتہ';

  @override
  String get relationshipRequiredHint => 'ضروری ہے (مثلاً بیٹا، بیٹی)';

  @override
  String get patientPortalAccessPasswordLabel => 'مریض پورٹل کا پاس ورڈ';

  @override
  String get passwordFailHelperText =>
      'فنگر پرنٹ یا بائیو میٹرک ناکام ہونے کی صورت میں استعمال ہوگا۔';

  @override
  String get passwordLengthError => 'پاس ورڈ کم از کم 6 ہندسوں کا ہونا چاہیے';

  @override
  String get setHomeAndSafeZone => 'گھر کا پتہ اور محفوظ زون منتخب کریں';

  @override
  String get useCurrentGpsLocationTooltip =>
      'موجودہ جی پی ایس لوکیشن استعمال کریں';

  @override
  String get tapMapSetHomeBaseHint =>
      'مریض کا مرکزی مقام منتخب کرنے کے لیے نقشے پر کہیں بھی ٹیپ کریں۔';

  @override
  String allowedSafeDistanceLabel(int distance) {
    return 'مجاز محفوظ فاصلہ: $distance میٹر';
  }

  @override
  String get registerPatientAndSaveLocationButton =>
      'مریض رجسٹر کریں اور لوکیشن محفوظ کریں';

  @override
  String get connectToExistingPatientHeader =>
      'موجودہ مریض کے پروفائل سے منسلک ہوں';

  @override
  String get connectPatientDescription =>
      'اس کیئرگیور پروفائل کو لنک کرنے کے لیے مریض کا رجسٹرڈ نام اور پاس ورڈ درج کریں۔';

  @override
  String get fullRegisteredPatientNameLabel => 'مریض کا پورا رجسٹرڈ نام';

  @override
  String get enterPatientSearchNameError =>
      'برائے مہربانی تلاش کے لیے مریض کا نام درج کریں';

  @override
  String get validationPasswordLabel => 'تصدیقی پاس ورڈ';

  @override
  String get enterPasswordError => 'برائے مہربانی پاس ورڈ درج کریں';

  @override
  String get validateAndLinkProfileButton => 'تصدیق کریں اور پروفائل لنک کریں';

  @override
  String get pickProfilePhotoPrompt =>
      'برائے مہربانی مریض کی پروفائل تصویر منتخب کریں';

  @override
  String get patientRegisteredSuccess => 'مریض کامیابی سے رجسٹر ہو گیا!';

  @override
  String registrationFailedError(String error) {
    return 'رجسٹریشن ناکام ہو گئی: $error';
  }

  @override
  String get noPatientFoundNameError => 'اس نام کا کوئی مریض نہیں ملا۔';

  @override
  String get incorrectPasswordError => 'اس مریض کا پاس ورڈ غلط ہے۔';

  @override
  String successfullyConnectedTo(String name) {
    return '$name کے ساتھ کامیابی سے لنک ہو گیا!';
  }

  @override
  String failedToLinkProfileError(String error) {
    return 'پروفائل لنک کرنے میں ناکامی: $error';
  }

  @override
  String get whoIsThisTitle => 'یہ کون ہے؟';

  @override
  String get pointCameraInstruction =>
      'کیمرا چہرے کی طرف کریں اور اسکین کا بٹن دبائیں';

  @override
  String get noCameraHardwareFound => 'کوئی کیمرا نہیں ملا۔';

  @override
  String cameraError(String error) {
    return 'کیمرا کی غلطی: $error';
  }

  @override
  String get analyzingFaceStructure => 'چہرے کی ساخت کا تجزیہ کیا جا رہا ہے...';

  @override
  String get noFaceDetected =>
      'کوئی چہرہ نہیں ملا۔ براہ راست کیمرے کی طرف دیکھیں۔';

  @override
  String get noTrustedFacesEnrolled =>
      'آپ کے کیئرگیور نے ابھی تک کوئی قابل اعتماد چہرہ شامل نہیں کیا ہے۔';

  @override
  String get matchFound => 'تطابق مل گیا!';

  @override
  String get unknownPerson =>
      'نامعلوم شخص۔ یہ شخص آپ کے سسٹم میں رجسٹرڈ نہیں ہے۔';

  @override
  String analysisError(String error) {
    return 'تجزیہ کی غلطی: $error';
  }

  @override
  String yourRelationship(String relationship) {
    return 'آپ کا $relationship';
  }

  @override
  String confidenceScore(String score) {
    return 'تطابق کا تناسب: $score%';
  }

  @override
  String get scanFaceButton => 'چہرہ اسکین کریں';

  @override
  String get processingButton => 'جاری ہے...';
}
