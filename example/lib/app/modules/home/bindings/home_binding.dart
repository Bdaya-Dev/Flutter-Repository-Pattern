import 'package:get/get.dart';

import 'package:bdaya_repository_pattern_example/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find()),
    );
  }
}
