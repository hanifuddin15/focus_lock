class AppInfoModel {
  final String packageName;
  final String appName;
  final String? category;
  bool isBlocked;
  bool isWhitelisted;

  AppInfoModel({
    required this.packageName,
    required this.appName,
    this.category,
    this.isBlocked = false,
    this.isWhitelisted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'category': category,
      'isBlocked': isBlocked,
      'isWhitelisted': isWhitelisted,
    };
  }

  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      category: map['category'] as String?,
      isBlocked: map['isBlocked'] as bool? ?? false,
      isWhitelisted: map['isWhitelisted'] as bool? ?? false,
    );
  }
}
