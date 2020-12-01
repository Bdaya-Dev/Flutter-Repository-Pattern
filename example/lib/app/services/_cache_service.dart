import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:bdaya_repository_pattern_example/app/data/_export_data.dart';
import 'package:bdaya_repository_pattern_example/app/services/user_repo.dart';
import 'package:get/get.dart';

class CacheService extends CacheServiceInterface {
  static CacheService get to => Get.find();

  final userRepo = UserRepo();

  @override
  Future<void> initRepos() async {
    registerTypeAdapters();
    await userRepo.init();
  }

  @override
  void registerTypeAdapters() {
    Hive.registerAdapter(UserAdapter());
  }
}
