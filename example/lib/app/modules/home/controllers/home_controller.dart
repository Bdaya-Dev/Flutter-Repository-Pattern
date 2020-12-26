import 'dart:async';

import 'package:bdaya_repository_pattern_example/app/data/_export_data.dart';
import 'package:bdaya_repository_pattern_example/app/services/_cache_service.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final CacheService cacheService;

  HomeController(this.cacheService);

  final usersList = <String, User>{}.obs;
  StreamSubscription sub;
  @override
  void onInit() {
    super.onInit();
    sub = cacheService.userRepo.stream.listen((event) {
      usersList.assignAll(event);
    });
  }

  Future<void> addTestData() async {
    await cacheService.userRepo.putAll({
      usersList.length.toString(): User()
        ..name = 'Ahmed ${usersList.length}'
        ..dob = DateTime.now()
    });
  }

  Future<void> clearData() async {
    await cacheService.userRepo.clear();
  }

  @override
  void onClose() async {
    await sub?.cancel();
    super.onClose();
  }
}
