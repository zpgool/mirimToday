import 'package:flutter/material.dart';
import '../models/timetable_data.dart';

class TimetableContainer extends StatelessWidget {
  final bool isDarkMode;
  final DateTime selectedDate;
  final String selectedGrade;
  final String selectedClass;
  final bool isLoading;
  final List timetableList;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onClassChanged;

  const TimetableContainer({
    super.key,
    required this.isDarkMode,
    required this.selectedDate,
    required this.selectedGrade,
    required this.selectedClass,
    required this.isLoading,
    required this.timetableList,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onToday,
    required this.onGradeChanged,
    required this.onClassChanged,
  });

  // UI에 보여줄 "MM/DD (요일)" 형태 변환
  String _formatDateToUI(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    String month = date.month.toString();
    String day = date.day.toString();
    String weekday = weekdays[date.weekday - 1];
    return "$month/$day ($weekday)";
  }

  // 교시별 고정 시간 변환
  String _getTimeString(int period) {
    switch (period) {
      case 1:
        return '8:20 ~ 9:10';
      case 2:
        return '9:20 ~ 10:10';
      case 3:
        return '10:20 ~ 11:10';
      case 4:
        return '11:20 ~ 12:10';
      case 5:
        return '1:10 ~ 2:00';
      case 6:
        return '2:10 ~ 3:00';
      case 7:
        return '3:10 ~ 4:00';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime yesterday = selectedDate.subtract(const Duration(days: 1));
    DateTime tomorrow = selectedDate.add(const Duration(days: 1));

    DateTime now = DateTime.now();
    bool isShowingToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // 1. 날짜 이동 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: onPrevDay,
                child: Text(
                  _formatDateToUI(yesterday),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatDateToUI(selectedDate),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onNextDay,
                child: Text(
                  _formatDateToUI(tomorrow),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. 오늘 바로가기 및 드롭다운 필터 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: isShowingToday ? null : onToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isShowingToday
                        ? (isDarkMode ? Colors.grey[800] : Colors.grey[300])
                        : const Color(0xff00845B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isShowingToday
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    '오늘',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isShowingToday
                          ? (isDarkMode ? Colors.grey[500] : Colors.grey[600])
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildDropdownButton(
                    selectedGrade,
                    ['1학년', '2학년', '3학년'],
                    isDarkMode,
                    onGradeChanged,
                  ),
                  const SizedBox(width: 16),
                  _buildDropdownButton(
                    selectedClass,
                    ['1반', '2반', '3반', '4반', '5반', '6반'],
                    isDarkMode,
                    onClassChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 3. 시간표 리스트 내용 표시
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : timetableList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      '등록된 시간표 정보가 없습니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: timetableList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = timetableList[index];
                    return _buildTimetableRow(item, isDarkMode);
                  },
                ),
        ],
      ),
    );
  }

  // 드롭다운 공통 버튼 컴포넌트
  Widget _buildDropdownButton(
    String value,
    List items,
    bool isDarkMode,
    ValueChanged<String?> onChanged,
  ) {
    final bgColor = isDarkMode ? const Color(0xff505050) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(16),
          elevation: 3,
          focusColor: Colors.transparent,
          itemHeight: 48,
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
          dropdownColor: bgColor,
        ),
      ),
    );
  }

  // 단일 교시 카드 컴포넌트
  Widget _buildTimetableRow(TimetableData item, bool isDarkMode) {
    final bgColor = isDarkMode ? const Color(0xff505050) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final boxShadow = isDarkMode
        ? null
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: boxShadow,
            ),
            child: Center(
              child: Text(
                _getTimeString(item.period),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: boxShadow,
              ),
              child: Row(
                children: [
                  Text(
                    '${item.period}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.teacher.isNotEmpty
                          ? '${item.subject}(${item.teacher})'
                          : item.subject,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
