import 'package:hive/hive.dart';

part 'request_model.g.dart';

@HiveType(typeId: 0)
class RequestModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String method; // GET, POST, PUT, DELETE, PATCH, etc.

  @HiveField(3)
  late String url;

  @HiveField(4)
  late List<HeaderModel> headers;

  @HiveField(5)
  late AuthModel? auth;

  @HiveField(6)
  late String bodyType; // none, formdata, x-www-form-urlencoded, raw

  @HiveField(7)
  late String body;

  @HiveField(8)
  late Map<String, String> params; // query parameters

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  late DateTime updatedAt;

  @HiveField(11)
  late String? environmentId;

  RequestModel({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    this.headers = const [],
    this.auth,
    this.bodyType = 'none',
    this.body = '',
    this.params = const {},
    required this.createdAt,
    required this.updatedAt,
    this.environmentId,
  });
}

@HiveType(typeId: 1)
class HeaderModel extends HiveObject {
  @HiveField(0)
  late String key;

  @HiveField(1)
  late String value;

  @HiveField(2)
  late bool isEnabled;

  HeaderModel({
    required this.key,
    required this.value,
    this.isEnabled = true,
  });
}

@HiveType(typeId: 2)
class AuthModel extends HiveObject {
  @HiveField(0)
  late String type; // basic, bearer, none

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String password;

  @HiveField(3)
  late String token;

  AuthModel({
    this.type = 'none',
    this.username = '',
    this.password = '',
    this.token = '',
  });
}