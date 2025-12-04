class Announcement {
  int? id;
  String title;
  String content;
  String date;

  Announcement({this.id, required this.title, required this.content, required this.date});

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'title': title,
      'content': content,
      'date': date,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  static Announcement fromMap(Map<String, dynamic> m) => Announcement(
    id: m['id'] as int?,
    title: m['title'] ?? '',
    content: m['content'] ?? '',
    date: m['date'] ?? '',
  );
}
