import 'package:bdaya_repository_pattern_example/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:bdaya_repository_pattern_example/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:bdaya_repository_pattern_example/app/modules/home/views/home_view.dart';
import 'package:bdaya_repository_pattern_example/app/modules/home/bindings/home_binding.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SPLASH_SCREEN,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
  ];
}
