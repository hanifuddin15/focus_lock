import 'package:hive/hive.dart';

part 'app_info_model.g.dart';

@HiveType(typeId: 1)
class AppInfoModel extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final String? category;

  @HiveField(3)
  bool isBlocked;

  @HiveField(4)
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
