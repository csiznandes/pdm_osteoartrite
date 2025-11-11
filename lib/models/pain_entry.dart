//Model das Dores
class PainEntry {
  int? id;
  int? userId;
  String date;
  int intensity;
  String? location;

  PainEntry({
    this.id,
    this.userId,
    required this.date,
    required this.intensity,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'intensity': intensity,
      'location': location,
    };
  }

  factory PainEntry.fromMap(Map<String, dynamic> m) {
    return PainEntry(
      id: m['id'],
      userId: m['userId'],
      date: m['date'],
      intensity: m['intensity'],
      location: m['location'],
    );
  }
}
