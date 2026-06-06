import 'package:get/get.dart';
import 'package:focus_lock/services/logger_service.dart';

enum SubscriptionTier {
  free,
  pro,
  premium,
}

class LicenseManager extends GetxService {
  final currentTier = SubscriptionTier.free.obs;
  final maxFreeSessions = 5;
  final maxFreeMinutes = 60;

  Future<LicenseManager> init() async {
    // In production, check stored subscription state
    // and verify with backend/App Store/Play Store
    LoggerService.info('LicenseManager initialized (tier: free)');
    return this;
  }

  bool get isPro =>
      currentTier.value == SubscriptionTier.pro ||
      currentTier.value == SubscriptionTier.premium;

  bool get isPremium => currentTier.value == SubscriptionTier.premium;

  bool canStartSession(int currentSessionCount) {
    if (isPro) return true;
    // Free tier: unlimited for now (monetization not active)
    return true;
  }

  int getMaxDurationMinutes() {
    if (isPro) return 180;
    // Free tier: unlimited for now
    return 180;
  }

  List<String> getProFeatures() {
    return [
      'Unlimited focus sessions',
      'Cloud backup & sync',
      'Detailed analytics & insights',
      'Custom challenge paragraphs',
      'Priority support',
    ];
  }

  Future<bool> purchasePro() async {
    // Placeholder for in-app purchase
    LoggerService.info('Pro purchase initiated (placeholder)');
    return false;
  }

  Future<bool> restorePurchases() async {
    // Placeholder for purchase restoration
    LoggerService.info('Restore purchases (placeholder)');
    return false;
  }
}
