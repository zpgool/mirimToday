import 'package:flutter/material.dart';

class MealContainer extends StatefulWidget {
  final bool isDarkMode;
  final DateTime selectedDate;
  final bool isLoading;
  final Map<String, String> mealData; 
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;

  const MealContainer({
    super.key,
    required this.isDarkMode,
    required this.selectedDate,
    required this.isLoading,
    required this.mealData,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onToday,
  });

  @override
  State<MealContainer> createState() => _MealContainerState();
}

class _MealContainerState extends State<MealContainer> {
  final PageController _pageController = PageController(initialPage: 1);
  bool _isSwiping = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MealContainer oldWidget) {
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
    return "${date.month}/${date.day} (${weekdays[date.weekday - 1]})";
  }

  Widget _buildDateRow(DateTime centerDate) {
    DateTime leftDate = centerDate.subtract(const Duration(days: 1));
    DateTime rightDate = centerDate.add(const Duration(days: 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(_formatDateToUI(leftDate), style: TextStyle(color: widget.isDarkMode ? Colors.grey[600] : Colors.black38, fontSize: 15)),
        Text(_formatDateToUI(centerDate), style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(_formatDateToUI(rightDate), style: TextStyle(color: widget.isDarkMode ? Colors.grey[600] : Colors.black38, fontSize: 15)),
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
          // 1. 날짜 바 스와이프 영역
          Listener(
            onPointerDown: (_) => setState(() => _isSwiping = true),
            onPointerUp: (_) => setState(() => _isSwiping = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                color: _isSwiping ? (widget.isDarkMode ? Colors.grey[800] : Colors.white) : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  if (page == 0) widget.onPrevDay();
                  else if (page == 2) widget.onNextDay();
                },
                children: [
                  _buildDateRow(widget.selectedDate.subtract(const Duration(days: 1))),
                  _buildDateRow(widget.selectedDate),
                  _buildDateRow(widget.selectedDate.add(const Duration(days: 1))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. 오늘 버튼
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
            ],
          ),
          const SizedBox(height: 15),

          // 3. 급식 카드 영역
          widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator(color: Color(0xff00845B))),
                )
              : Column(
                  children: [
                    _buildMealCard('조식', widget.mealData['조식'] ?? '', widget.isDarkMode),
                    const SizedBox(height: 16),
                    _buildMealCard('중식', widget.mealData['중식'] ?? '', widget.isDarkMode),
                    const SizedBox(height: 16),
                    _buildMealCard('석식', widget.mealData['석식'] ?? '', widget.isDarkMode),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String type, String menu, bool isDarkMode) {
    final bgColor = isDarkMode ? const Color(0xff505050) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              type,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              menu,
              style: TextStyle(
                height: 1.5,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}