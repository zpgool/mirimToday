import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // 기본값은 라이트 모드
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // 다크모드 여부 확인
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // 테마 전환 함수
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // 앱 전체에 테마가 바뀌었다고 알림
  }
}