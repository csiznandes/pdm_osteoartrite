//Model dos Usuários
class User {
  int? id;
  String name;
  String email;
  String password;
  int? age;
  String? sex;
  String? contact;
  String? diagnosis;
  String? comorbidities;
  String? accessibility;
  bool lgpd;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.age,
    this.sex,
    this.contact,
    this.diagnosis,
    this.comorbidities,
    this.accessibility,
    this.lgpd = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'sex': sex,
      'contact': contact,
      'diagnosis': diagnosis,
      'comorbidities': comorbidities,
      'accessibility': accessibility,
      'lgpd': lgpd ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> m) {
    return User(
      id: m['id'],
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      password: m['password'] ?? '',
      age: m['age'],
      sex: m['sex'],
      contact: m['contact'],
      diagnosis: m['diagnosis'],
      comorbidities: m['comorbidities'],
      accessibility: m['accessibility'],
      lgpd: (m['lgpd'] ?? 0) == 1,
    );
  }
}
