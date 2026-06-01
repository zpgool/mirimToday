import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class CustomTabBar extends StatelessWidget {
final int currentTab;
final ValueChanged onTabChanged;
final ThemeProvider themeProvider;

const CustomTabBar({
super.key,
required this.currentTab,
required this.onTabChanged,
required this.themeProvider,
});

@override
Widget build(BuildContext context) {
return LayoutBuilder(
builder: (context, constraints) {
// 좌우 여백 및 간격을 고려한 탭 하나의 너비 계산
double tabWidth = (constraints.maxWidth - 10) / 2;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.grey[800]
            : const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          children: [
            // 선택된 탭 배경 슬라이드 애니메이션
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              left: currentTab == 0 ? 0 : tabWidth,
              width: tabWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? const Color(0xff505050)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                // 시간표 탭 버튼
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTabChanged(0),
                    child: Center(
                      child: Text(
                        '시간표',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: currentTab == 0
                              ? (themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // 급식표 탭 버튼
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTabChanged(1),
                    child: Center(
                      child: Text(
                        '급식표',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: currentTab == 1
                              ? (themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
);


}
}