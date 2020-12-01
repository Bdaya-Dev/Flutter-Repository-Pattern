import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:bdaya_repository_pattern_example/app/data/user.dart';

class UserRepo extends ActiveRepo<String, User> {
  @override
  String get boxName => "users";
}
