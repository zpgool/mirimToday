import 'package:flutter/material.dart';

class MealContainer extends StatelessWidget {
final bool isDarkMode;

const MealContainer({
super.key,
required this.isDarkMode,
});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
height: 400, // 탭 전환 대응을 위한 가이드 영역
decoration: BoxDecoration(
color: isDarkMode ? Colors.grey[850] : Colors.white,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Center(
child: Text(
'여기에 급식표 UI를 만들어볼까요?',
style: TextStyle(
fontSize: 18,
color: isDarkMode ? Colors.white54 : Colors.grey,
),
),
),
);
}
}