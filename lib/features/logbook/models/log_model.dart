import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id;
  final String username;
  final String title;
  final String timestamp;
  final String description;
  final String category;

  LogModel({
    this.id,
    required this.username,
    required this.title,
    required this.timestamp,
    required this.description,
    this.category = 'Pribadi',
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?,
      username: map['username'] ?? '',
      title: map['title'] ?? '',
      timestamp: map['timestamp'] ?? map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'username': username,
      'title': title,
      'timestamp': timestamp,
      'description': description,
      'category': category,
    };
  }
}
