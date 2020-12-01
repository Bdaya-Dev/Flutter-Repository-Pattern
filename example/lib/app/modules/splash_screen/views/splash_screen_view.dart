import 'package:bdaya_custom_splash/bdaya_custom_splash.dart';
import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:bdaya_repository_pattern_example/app/routes/app_pages.dart';
import 'package:bdaya_repository_pattern_example/app/services/_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bdaya_repository_pattern_example/app/modules/splash_screen/controllers/splash_screen_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BdayaCustomSplash(
        backgroundBuilder: (child) {
          return child;
        },
        initFunction: () async {
          await Hive.initFlutter('v1');
          await Get.putAsync(() async {
            final cacheService = CacheService();
            await cacheService.initRepos();
            return cacheService;
          });

          return null;
        },
        onNavigateTo: (res) {
          Get.offNamed(Routes.HOME);
        },
        logoBuilder: () => Center(
          child: Container(
            color: Colors.red,
            height: Get.height / 2,
            width: Get.width / 2,
          ),
        ),
      ),
    );
  }
}
