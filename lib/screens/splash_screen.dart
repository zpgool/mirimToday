import 'dart:async'; // 🚨 타이머를 쓰기 위해 상단에 추가 필수!
import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';

// 🚨 타이머 작동을 위해 StatefulWidget으로 변경합니다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 270),
              const Text(
                '미림 오늘',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Text('하루를 편리하게', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 230),
        
              Image.asset('lib/assets/img/mirim_logo.png', width: 110),
        
              const SizedBox(height: 20),
        
              const Text(
                '미림마이스터고등학교',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff00845B),
                  height: 1.2,
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEWMEDIA CONTENTS ', // 뒤에 공백을 한 칸 주면 자연스럽게 떨어집니다.
                    style: TextStyle(fontSize: 6, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'MIRIM MEISTER SCHOOL',
                    style: TextStyle(fontSize: 6, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
