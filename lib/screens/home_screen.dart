import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../models/timetable_data.dart';
import '../widgets/today_date.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/timetable_container.dart';
import '../widgets/meal_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  int _currentTab = 0;

  DateTime _selectedDate = DateTime.now();
  String _selectedGrade = '2학년';
  String _selectedClass = '2반';
  bool _isLoading = false;

  List _timetableList = [];

  @override
  void initState() {
    super.initState();
    fetchTimetable();
  }

  // DateTime 객체를 "YYYYMMDD" 형식의 문자열로 변환
  String _formatDateToParam(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return "$year$month$day";
  }

  // 백엔드 서버와 통신하여 시간표를 가져오는 비동기 함수
  Future fetchTimetable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gradeNum = _selectedGrade.replaceAll('학년', '');
      final classNum = _selectedClass.replaceAll('반', '');
      final dateParam = _formatDateToParam(_selectedDate);

      final url = Uri.parse(
        'http://localhost:3000/api/timetable?date=$dateParam&grade=$gradeNum&class_num=$classNum',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> targetList = [];

        if (decodedData is List) {
          targetList = decodedData;
        } else if (decodedData is Map) {
          try {
            targetList =
                decodedData.values.firstWhere((value) => value is List)
                    as List<dynamic>;
          } catch (e) {
            throw Exception('JSON 데이터 안에서 시간표 배열을 찾을 수 없습니다.');
          }
        }

        setState(() {
          _timetableList = targetList
              .map((json) => TimetableData.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('서버 에러 발생 (코드: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _timetableList = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('시간표를 불러오지 못했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : const Color(0xffFAFAFA),
        title: const Text(
          '미림마이스터고등학교',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          CupertinoSwitch(
            value: isDark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            activeColor: const Color(0xff00845B),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CurrentDateWidget(),
              const SizedBox(height: 20),

              // 1. 커스텀 탭 바 영역 (위젯 분리 적용)
              CustomTabBar(
                currentTab: _currentTab,
                themeProvider: themeProvider,
                onTabChanged: (index) {
                  setState(() => _currentTab = index);
                },
              ),
              const SizedBox(height: 20),

              // 2. 탭 선택에 따른 컨테이너 출력 (위젯 분리 적용)
              _currentTab == 0
                  ? TimetableContainer(
                      isDarkMode: isDark,
                      selectedDate: _selectedDate,
                      selectedGrade: _selectedGrade,
                      selectedClass: _selectedClass,
                      isLoading: _isLoading,
                      timetableList: _timetableList,
                      onPrevDay: () {
                        setState(
                          () => _selectedDate = _selectedDate.subtract(
                            const Duration(days: 1),
                          ),
                        );
                        fetchTimetable();
                      },
                      onNextDay: () {
                        setState(
                          () => _selectedDate = _selectedDate.add(
                            const Duration(days: 1),
                          ),
                        );
                        fetchTimetable();
                      },
                      onToday: () {
                        setState(() => _selectedDate = DateTime.now());
                        fetchTimetable();
                      },
                      onGradeChanged: (val) {
                        setState(() => _selectedGrade = val!);
                        fetchTimetable();
                      },
                      onClassChanged: (val) {
                        setState(() => _selectedClass = val!);
                        fetchTimetable();
                      },
                    )
                  : MealContainer(isDarkMode: isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
