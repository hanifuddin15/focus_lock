import 'package:hive/hive.dart';

part 'user_settings_model.g.dart';

@HiveType(typeId: 2)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  String challengeType; // 'barcode' or 'typing'

  @HiveField(1)
  String? savedBarcodeHash;

  @HiveField(2)
  String? savedBarcodeValue;

  @HiveField(3)
  List<String> whitelistedApps;

  @HiveField(4)
  bool weeklyReportEnabled;

  @HiveField(5)
  bool onboardingCompleted;

  @HiveField(6)
  String subscriptionTier; // 'free', 'pro', 'premium'

  @HiveField(7)
  int defaultDurationMinutes;

  @HiveField(8)
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
}
