class NotificationSchedule {
  String day;
  int hour;
  int minute;
  String title;
  String body;

  NotificationSchedule({
    required this.day,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'hour': hour,
      'minute': minute,
      'title': title,
      'body': body,
    };
  }

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) {
    return NotificationSchedule(
      day: json['day'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}
