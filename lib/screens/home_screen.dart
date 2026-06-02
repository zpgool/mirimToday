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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  DateTime _selectedDate = DateTime.now();
  String _selectedGrade = '1학년';
  String _selectedClass = '1반';
  
  bool _isLoading = false;
  List<TimetableData> _timetableList = [];
  
  // 급식 데이터를 담아둘 변수 (기본값 설정)
  Map<String, String> _mealData = {
    '조식': '등록된 조식 정보가 없습니다.', 
    '중식': '등록된 중식 정보가 없습니다.', 
    '석식': '등록된 석식 정보가 없습니다.'
  };

  @override
  void initState() {
    super.initState();
    _fetchCurrentTabData();
  }

  void _fetchCurrentTabData() {
    if (_currentTab == 0) {
      fetchTimetable();
    } else {
      fetchMeal();
    }
  }

  String _formatDateToParam(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return "$year$month$day";
  }

  // 시간표 데이터 패치 함수
  Future<void> fetchTimetable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gradeNum = _selectedGrade.replaceAll('학년', '');
      final classNum = _selectedClass.replaceAll('반', '');
      final dateParam = _formatDateToParam(_selectedDate);

      final url = Uri.parse(
        'https://mirimtoday.onrender.com/api/timetable?date=$dateParam&grade=$gradeNum&class_num=$classNum',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> targetList = [];

        if (decodedData is List) {
          targetList = decodedData;
        } else if (decodedData is Map) {
          try {
            targetList = decodedData.values.firstWhere((value) => value is List) as List<dynamic>;
          } catch (e) {
            throw Exception('JSON 데이터 안에서 시간표 배열을 찾을 수 없습니다.');
          }
        }

        setState(() {
          _timetableList = targetList.map((json) => TimetableData.fromJson(json)).toList();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('시간표를 불러오지 못했습니다: $e')),
        );
      }
    }
  }

  // 🌟 [최종 수정] 급식 데이터 패치 함수 ('data' 키 안의 리스트를 파싱)
  Future<void> fetchMeal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateParam = _formatDateToParam(_selectedDate);
      final url = Uri.parse('https://mirimtoday.onrender.com/api/meals?date=$dateParam');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        
        // 데이터가 없을 때를 대비한 기본 문구
        Map<String, String> tempMeal = {
          '조식': '등록된 조식 정보가 없습니다.',
          '중식': '등록된 중식 정보가 없습니다.',
          '석식': '등록된 석식 정보가 없습니다.'
        };

        // JSON 구조: {"success": true, "data": [{...}, {...}]}
        if (decodedData is Map && decodedData['data'] is List) {
          final List<dynamic> mealList = decodedData['data'];
          
          for (var item in mealList) {
            String type = item['meal_type'] ?? ''; 
            String menu = item['menu'] ?? '';
            
            if (tempMeal.containsKey(type)) {
              tempMeal[type] = menu;
            }
          }
        }

        setState(() {
          _mealData = tempMeal;
          _isLoading = false;
        });
      } else {
        throw Exception('서버 에러 발생 (코드: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _mealData = {'조식': '불러오기 실패', '중식': '불러오기 실패', '석식': '불러오기 실패'};
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('급식 정보를 불러오지 못했습니다: $e')),
        );
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
            onChanged: (value) => themeProvider.toggleTheme(value),
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

              CustomTabBar(
                currentTab: _currentTab,
                themeProvider: themeProvider,
                onTabChanged: (index) {
                  setState(() => _currentTab = index);
                  _fetchCurrentTabData();
                },
              ),
              const SizedBox(height: 20),

              _currentTab == 0
                  ? TimetableContainer(
                      isDarkMode: isDark,
                      selectedDate: _selectedDate,
                      selectedGrade: _selectedGrade,
                      selectedClass: _selectedClass,
                      isLoading: _isLoading,
                      timetableList: _timetableList,
                      onPrevDay: () {
                        setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                        fetchTimetable();
                      },
                      onNextDay: () {
                        setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
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
                  : MealContainer(
                      isDarkMode: isDark,
                      selectedDate: _selectedDate,
                      isLoading: _isLoading,
                      mealData: _mealData,
                      onPrevDay: () {
                        setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                        fetchMeal();
                      },
                      onNextDay: () {
                        setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                        fetchMeal();
                      },
                      onToday: () {
                        setState(() => _selectedDate = DateTime.now());
                        fetchMeal();
                      },
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}