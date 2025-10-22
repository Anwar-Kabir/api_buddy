import 'package:hive/hive.dart';

part 'enviroment_model.g.dart';

@HiveType(typeId: 3)
class EnvironmentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late Map<String, String> variables; // {{base_url}}, {{token}}, etc.

  @HiveField(3)
  late bool isActive;

  @HiveField(4)
  late DateTime createdAt;

  EnvironmentModel({
    required this.id,
    required this.name,
    this.variables = const {},
    this.isActive = false,
    required this.createdAt,
  });
}