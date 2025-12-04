class ActivityModel {
  int? id;
  String title;
  String description;
  String date;
  String time;
  String location;
  String userEmail;
  String? photoPath;

  ActivityModel({this.id, required this.title, required this.description, required this.date, required this.time, required this.location, required this.userEmail, this.photoPath});

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'user_email': userEmail,
      'photo_path': photoPath,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  static ActivityModel fromMap(Map<String, dynamic> m) => ActivityModel(
    id: m['id'] as int?,
    title: m['title'] ?? '',
    description: m['description'] ?? '',
    date: m['date'] ?? '',
    time: m['time'] ?? '',
    location: m['location'] ?? '',
    userEmail: m['user_email'] ?? '',
    photoPath: m['photo_path'],
  );
}
