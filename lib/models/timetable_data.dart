// 시간표 데이터 모델 클래스 분리
class TimetableData {
final String time;
final int period;
final String subject;
final String teacher;

TimetableData({
required this.time,
required this.period,
required this.subject,
required this.teacher,
});

factory TimetableData.fromJson(Map<String, dynamic> json) {
return TimetableData(
time: json['time'] ?? '',
period: json['period'] ?? 0,
subject: json['subject'] ?? '',
teacher: json['teacher'] ?? '',
);
}
}