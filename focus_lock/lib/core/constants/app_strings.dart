class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Deep Focus';
  static const String appTagline = 'Unbreakable Focus Lock';

  // Onboarding
  static const String onboardingTitle1 = 'Unbreakable Focus';
  static const String onboardingDesc1 =
      'Set a timer, select distracting apps, and lock them away. No "Ignore" button, no easy escape.';
  static const String onboardingTitle2 = 'Smart Challenges';
  static const String onboardingDesc2 =
      'Want to break early? You\'ll need to scan a barcode from another room or type a 200-word paragraph with zero typos.';
  static const String onboardingTitle3 = 'Track Your Growth';
  static const String onboardingDesc3 =
      'Watch your focus hours grow. See your streaks, completed sessions, and early break attempts.';
  static const String getStarted = 'Get Started';
  static const String next = 'Next';
  static const String skip = 'Skip';

  // Home
  static const String homeTitle = 'Focus Session';
  static const String selectApps = 'Select Apps to Block';
  static const String startFocusLock = 'Start Focus Lock';
  static const String minutes = 'min';
  static const String hours = 'h';
  static const String custom = 'Custom';
  static const String noAppsFound = 'No apps found. Grant permission to see installed apps.';
  static const String searchApps = 'Search apps...';
  static const String selectAll = 'Select All';
  static const String deselectAll = 'Deselect All';

  // Lock Screen
  static const String focusMode = 'FOCUS MODE';
  static const String timeRemaining = 'Time Remaining';
  static const String earlyBreakLock = 'Early Break Lock';
  static const String stayFocused = 'Stay Focused!';
  static const String sessionComplete = 'Session Complete!';
  static const String greatWork = 'Great work! You stayed focused.';
  static const String sessionFailed = 'Session ended early.';

  // Challenge
  static const String challengeTitle = 'Break Lock Challenge';
  static const String challengeDesc =
      'Complete this challenge to unlock early. Are you sure you want to break your focus?';
  static const String barcodeChallengeTitle = 'Scan Your Barcode';
  static const String barcodeChallengeDesc =
      'Scan the barcode you saved earlier. It should be in another room — walk there to unlock.';
  static const String typingChallengeTitle = 'Typing Challenge';
  static const String typingChallengeDesc =
      'Type the paragraph below with zero typos. Case-sensitive, punctuation matters. No copy-paste.';
  static const String scanBarcode = 'Point camera at barcode';
  static const String barcodeMatched = 'Barcode matched! Unlocking...';
  static const String barcodeNotMatched = 'Barcode does not match. Try again.';
  static const String typingSuccess = 'Perfect! Challenge complete.';
  static const String typingFailed = 'Typo detected! Start over.';
  static const String challengeFailed = 'Challenge failed. Focus continues.';
  static const String wordsRemaining = 'words remaining';
  static const String accuracy = 'Accuracy';
  static const String cancel = 'Cancel';
  static const String submit = 'Submit';
  static const String goBack = 'Go Back';

  // Typing Challenge Paragraph
  static const String typingParagraph =
      'The fundamental principles of cognitive neuroscience suggest that sustained '
      'attention requires the prefrontal cortex to actively suppress irrelevant stimuli. '
      'Modern digital environments, characterized by constant notifications and algorithmic '
      'content feeds, systematically exploit the brain\'s novelty-seeking mechanisms. Research '
      'published in the Journal of Experimental Psychology demonstrates that even brief '
      'exposure to smartphone notifications significantly reduces cognitive performance on '
      'subsequent tasks. The phenomenon known as "attention residue" means that switching '
      'between applications creates a persistent cognitive cost that accumulates throughout '
      'the day. Deliberate practice in maintaining focused attention, combined with '
      'environmental design that minimizes interruptions, represents the most effective '
      'strategy for improving deep work capacity. Studies from Stanford University confirm '
      'that individuals who regularly engage in single-task focused sessions show measurable '
      'improvements in working memory, creative problem-solving, and overall cognitive '
      'resilience against digital distractions.';

  // Statistics
  static const String statistics = 'Statistics';
  static const String totalSessions = 'Total Sessions';
  static const String totalFocusHours = 'Focus Hours';
  static const String completedSessions = 'Completed';
  static const String earlyBreaks = 'Early Breaks';
  static const String currentStreak = 'Current Streak';
  static const String bestStreak = 'Best Streak';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String allTime = 'All Time';
  static const String noSessionsYet = 'No focus sessions yet.\nStart your first session!';
  static const String focusMinutes = 'Focus Minutes';
  static const String days = 'days';

  // Settings
  static const String settings = 'Settings';
  static const String challengeType = 'Challenge Type';
  static const String barcodeScan = 'Barcode Scan';
  static const String typingTest = 'Typing Test';
  static const String savedBarcode = 'Saved Barcode';
  static const String scanAndSave = 'Scan & Save Barcode';
  static const String scanNewBarcode = 'Scan New Barcode';
  static const String barcodeNotSet = 'No barcode saved yet';
  static const String barcodeSaved = 'Barcode saved successfully!';
  static const String whitelistedApps = 'Whitelisted Apps';
  static const String whitelistDesc = 'These apps will never be blocked';
  static const String weeklyReport = 'Weekly Report';
  static const String weeklyReportDesc = 'Receive a summary every Sunday';
  static const String about = 'About';
  static const String version = 'Version';
  static const String permissions = 'Permissions';
  static const String grantPermissions = 'Grant Required Permissions';
  static const String permissionUsageStats = 'Usage Stats Access';
  static const String permissionOverlay = 'Display Over Other Apps';
  static const String permissionCamera = 'Camera Access';
  static const String permissionNotification = 'Notifications';
  static const String granted = 'Granted';
  static const String notGranted = 'Tap to grant';
  static const String pro = 'Pro';
  static const String upgradeToPro = 'Upgrade to Pro';
  static const String proFeatures = 'Unlimited sessions, cloud backup, and more';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorPermission = 'Permission required to continue.';
  static const String errorPlatformNotSupported = 'This feature is not supported on your device.';
  static const String errorNoBarcodeSet =
      'No barcode saved. Please save a barcode in Settings first.';
  static const String errorCameraAccess = 'Camera access is required for barcode scanning.';

  // Misc
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String confirm = 'Confirm';
  static const String areYouSure = 'Are you sure?';
  static const String loading = 'Loading...';
}
