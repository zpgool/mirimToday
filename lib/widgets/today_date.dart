import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentDateWidget extends StatefulWidget {
  const CurrentDateWidget({super.key});

  @override
  State<CurrentDateWidget> createState() => _CurrentDateWidgetState();
}

class _CurrentDateWidgetState extends State<CurrentDateWidget> {
  late Timer _timer;
  // 🚨 선언과 동시에 즉시 초기값을 넣어주어 타이밍 에러(late 관련)를 원천 차단합니다.
  String _formattedDate = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    
    // 1분마다 날짜가 바뀌었는지 체크하는 타이머
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final String newDate = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(DateTime.now());
      
      // 날짜 글자가 실제로 바뀌었을 때만 안전하게 화면을 새로 그립니다.
      if (mounted && _formattedDate != newDate) {
        setState(() {
          _formattedDate = newDate;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedDate,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}