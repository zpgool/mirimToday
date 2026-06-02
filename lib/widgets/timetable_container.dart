import 'package:flutter/material.dart';
import '../models/timetable_data.dart';

class TimetableContainer extends StatefulWidget {
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

  @override
  State<TimetableContainer> createState() => _TimetableContainerState();
}

class _TimetableContainerState extends State<TimetableContainer> {
  final PageController _pageController = PageController(initialPage: 1);
  bool _isSwiping = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimetableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(1);
        }
      });
    }
  }

  String _formatDateToUI(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    String month = date.month.toString();
    String day = date.day.toString();
    String weekday = weekdays[date.weekday - 1];
    return "$month/$day ($weekday)";
  }

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

  Widget _buildDateRow(DateTime centerDate) {
    DateTime leftDate = centerDate.subtract(const Duration(days: 1));
    DateTime rightDate = centerDate.add(const Duration(days: 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          _formatDateToUI(leftDate),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[600] : Colors.black38,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _formatDateToUI(centerDate),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _formatDateToUI(rightDate),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[600] : Colors.black38,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    bool isShowingToday =
        widget.selectedDate.year == now.year &&
        widget.selectedDate.month == now.month &&
        widget.selectedDate.day == now.day;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[850] : const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Listener(
            onPointerDown: (_) => setState(() => _isSwiping = true),
            onPointerUp: (_) => setState(() => _isSwiping = false),
            onPointerCancel: (_) => setState(() => _isSwiping = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isSwiping
                    ? (widget.isDarkMode ? Colors.grey[800] : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: _isSwiping && !widget.isDarkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  if (page == 0) {
                    widget.onPrevDay();
                  } else if (page == 2) {
                    widget.onNextDay();
                  }
                },
                children: [
                  _buildDateRow(widget.selectedDate.subtract(const Duration(days: 1))),
                  _buildDateRow(widget.selectedDate),
                  _buildDateRow(widget.selectedDate.add(const Duration(days: 1))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: isShowingToday ? null : widget.onToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isShowingToday
                        ? (widget.isDarkMode ? Colors.grey[800] : Colors.grey[300])
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
                          ? (widget.isDarkMode ? Colors.grey[500] : Colors.grey[600])
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildDropdownButton(
                    widget.selectedGrade,
                    ['1학년', '2학년', '3학년'],
                    widget.isDarkMode,
                    widget.onGradeChanged,
                  ),
                  const SizedBox(width: 16),
                  _buildDropdownButton(
                    widget.selectedClass,
                    ['1반', '2반', '3반', '4반', '5반', '6반'],
                    widget.isDarkMode,
                    widget.onClassChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : widget.timetableList.isEmpty
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
                  itemCount: widget.timetableList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = widget.timetableList[index];
                    return _buildTimetableRow(item, widget.isDarkMode);
                  },
                ),
        ],
      ),
    );
  }

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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                        fontSize: 13,
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