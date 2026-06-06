class BlockedApp {
  final String packageName;
  final String appName;
  final String? category;
  final bool isBlocked;
  final bool isWhitelisted;

  const BlockedApp({
    required this.packageName,
    required this.appName,
    this.category,
    this.isBlocked = false,
    this.isWhitelisted = false,
  });

  BlockedApp copyWith({
    bool? isBlocked,
    bool? isWhitelisted,
  }) {
    return BlockedApp(
      packageName: packageName,
      appName: appName,
      category: category,
      isBlocked: isBlocked ?? this.isBlocked,
      isWhitelisted: isWhitelisted ?? this.isWhitelisted,
    );
  }
}
