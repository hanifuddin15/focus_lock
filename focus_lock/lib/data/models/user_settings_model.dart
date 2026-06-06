class UserSettingsModel {
  String challengeType; // 'barcode' or 'typing'
  String? savedBarcodeHash;
  String? savedBarcodeValue;
  List<String> whitelistedApps;
  bool weeklyReportEnabled;
  bool onboardingCompleted;
  String subscriptionTier; // 'free', 'pro', 'premium'
  int defaultDurationMinutes;
  List<String> lastBlockedApps;

  UserSettingsModel({
    this.challengeType = 'typing',
    this.savedBarcodeHash,
    this.savedBarcodeValue,
    List<String>? whitelistedApps,
    this.weeklyReportEnabled = false,
    this.onboardingCompleted = false,
    this.subscriptionTier = 'free',
    this.defaultDurationMinutes = 30,
    List<String>? lastBlockedApps,
  })  : whitelistedApps = whitelistedApps ?? [],
        lastBlockedApps = lastBlockedApps ?? [];

  UserSettingsModel copyWith({
    String? challengeType,
    String? savedBarcodeHash,
    String? savedBarcodeValue,
    List<String>? whitelistedApps,
    bool? weeklyReportEnabled,
    bool? onboardingCompleted,
    String? subscriptionTier,
    int? defaultDurationMinutes,
    List<String>? lastBlockedApps,
  }) {
    return UserSettingsModel(
      challengeType: challengeType ?? this.challengeType,
      savedBarcodeHash: savedBarcodeHash ?? this.savedBarcodeHash,
      savedBarcodeValue: savedBarcodeValue ?? this.savedBarcodeValue,
      whitelistedApps: whitelistedApps ?? this.whitelistedApps,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      lastBlockedApps: lastBlockedApps ?? this.lastBlockedApps,
    );
  }

  bool get isBarcodeChallenge => challengeType == 'barcode';
  bool get isTypingChallenge => challengeType == 'typing';
  bool get hasSavedBarcode =>
      savedBarcodeHash != null && savedBarcodeHash!.isNotEmpty;
  bool get isPro => subscriptionTier == 'pro' || subscriptionTier == 'premium';

  Map<String, dynamic> toMap() {
    return {
      'challengeType': challengeType,
      'savedBarcodeHash': savedBarcodeHash,
      'savedBarcodeValue': savedBarcodeValue,
      'whitelistedApps': whitelistedApps,
      'weeklyReportEnabled': weeklyReportEnabled,
      'onboardingCompleted': onboardingCompleted,
      'subscriptionTier': subscriptionTier,
      'defaultDurationMinutes': defaultDurationMinutes,
      'lastBlockedApps': lastBlockedApps,
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      challengeType: map['challengeType'] as String? ?? 'typing',
      savedBarcodeHash: map['savedBarcodeHash'] as String?,
      savedBarcodeValue: map['savedBarcodeValue'] as String?,
      whitelistedApps: map['whitelistedApps'] != null 
          ? List<String>.from(map['whitelistedApps'] as List) 
          : [],
      weeklyReportEnabled: map['weeklyReportEnabled'] as bool? ?? false,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      subscriptionTier: map['subscriptionTier'] as String? ?? 'free',
      defaultDurationMinutes: map['defaultDurationMinutes'] as int? ?? 30,
      lastBlockedApps: map['lastBlockedApps'] != null
          ? List<String>.from(map['lastBlockedApps'] as List)
          : [],
    );
  }
}
