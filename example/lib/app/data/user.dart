import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends GuidHiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  DateTime dob;
}
