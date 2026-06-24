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
  Map<String, String> _allergyData = {'조식': '', '중식': '', '석식': ''};

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
        Map<String, String> tempAllergy = {'조식': '', '중식': '', '석식': ''};

        if (decodedData is Map && decodedData['data'] is List) {
          final List<dynamic> mealList = decodedData['data'];

          for (var item in mealList) {
            String type = item['meal_type'] ?? '';
            String menu = item['menu'] ?? '';
            String allergy = item['allergy_info'] ?? '';

            if (tempMeal.containsKey(type)) {
              tempMeal[type] = menu;
              tempAllergy[type] = allergy;
            }
          }
        }

        setState(() {
          _mealData = tempMeal;
          _allergyData = tempAllergy;
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

  Future<void> updateMeal(String mealType, String menu) async {
    final dateParam = _formatDateToParam(_selectedDate);
    final url = Uri.parse('https://mirimtoday.onrender.com/api/meals');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': dateParam,
          'meal_type': mealType,
          'menu': menu,
          'allergy_info': _allergyData[mealType] ?? '',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _mealData[mealType] = menu;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('급식 정보가 수정되었습니다.')),
          );
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 날짜의 급식 정보가 없습니다. 먼저 급식 탭을 열어 데이터를 불러와 주세요.')),
          );
        }
      } else {
        throw Exception('서버 에러 (코드: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정에 실패했습니다: $e')),
        );
      }
    }
  }

  void _showEditMealBottomSheet(String mealType) {
    final cleanedMenu = (_mealData[mealType] ?? '').replaceAll(RegExp(r'\([A-Za-z\d가-힣.]+\)'), '').trim();
    final items = cleanedMenu.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final controllers = items.map((item) => TextEditingController(text: item)).toList();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$mealType 수정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: controllers.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextField(
                                controller: entry.value,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xff00845B)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                final newMenu = controllers
                                    .map((c) => c.text.trim())
                                    .where((t) => t.isNotEmpty)
                                    .join('\n');
                                Navigator.pop(ctx);
                                await updateMeal(mealType, newMenu);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff00845B),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                '저장',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
            activeTrackColor: const Color(0xff00845B),
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
                      onEdit: _showEditMealBottomSheet,
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}