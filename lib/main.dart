import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 비동기 데이터 초기화를 위해 필수적인 한 줄
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 한국어 날짜 포맷(요일 등)을 초기화합니다.
  await initializeDateFormatting('ko_KR', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider를 지켜봅니다.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '미림 오늘',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode, // 현재 테마 모드 적용
          theme: ThemeData.light(), // 라이트 테마 정의
          darkTheme: ThemeData.dark(), // 다크 테마 정의
          // 🚨 라우터 설정 적용
          initialRoute: AppRoutes.splash, // 앱이 켜지면 처음 보여줄 주소 (/)
          onGenerateRoute: AppRoutes.generateRoute, // 라우터 매핑 함수 연결
        );
      },
    );
  }
}
