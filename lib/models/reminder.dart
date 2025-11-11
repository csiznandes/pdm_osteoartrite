//Model dos Reminders
class Reminder {
  int? id;
  int? userId;
  String date;
  String time;
  String description;

  Reminder({this.id, this.userId, required this.date, required this.time, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'time': time,
      'description': description,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> m) {
    return Reminder(
      id: m['id'],
      userId: m['userId'],
      date: m['date'],
      time: m['time'],
      description: m['description'],
    );
  }
}
