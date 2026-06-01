import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/home_screen.dart';

class AppRoutes {
  // 화면 주소(Route Name) 정의
  static const String splash = '/';
  static const String home = '/home';

  // 주소에 맞는 화면을 매핑해주는 라우터 함수
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return _createFadeRoute(const HomeScreen());
      default:
        // 정의되지 않은 주소로 갔을 때 에러 화면 처리
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static PageRouteBuilder _createFadeRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      // 화면이 스르륵 바뀌는 시간 설정 (500밀리초 = 0.5초)
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 투명도(Opacity)가 0.0에서 1.0으로 부드럽게 변하는 애니메이션 적용
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
