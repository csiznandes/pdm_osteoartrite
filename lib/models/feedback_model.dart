//Model dos Feedbacks
class FeedbackModel {
  int? id;
  int? userId;
  String date;
  String text;

  FeedbackModel({this.id, this.userId, required this.date, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'text': text,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> m) {
    return FeedbackModel(
      id: m['id'],
      userId: m['userId'],
      date: m['date'],
      text: m['text'],
    );
  }
}
