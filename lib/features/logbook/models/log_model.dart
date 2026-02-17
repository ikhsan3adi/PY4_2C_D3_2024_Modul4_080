class LogModel {
  final String title;
  final String timestamp;
  final String description;
  final String category;

  LogModel({
    required this.title,
    required this.timestamp,
    required this.description,
    this.category = 'Pribadi',
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'],
      timestamp: map['timestamp'] ?? map['date'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'Pribadi',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': timestamp,
      'description': description,
      'category': category,
    };
  }
}
