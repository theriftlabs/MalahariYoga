import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  
  // Hierarchy Links
  final String categoryId;
  final String parentCategoryId;

  // Calendar Data
  final String startTime; // "HH:mm" 24h format
  final String endTime;   // "HH:mm" 24h format
  final List<String> days; // ["Mon", "Wed", "Fri"]
  final DateTime startDate;
  final DateTime endDate;

  final int capacity;
  final String status; // "active" | "paused" | "completed"
  final bool inviteEnabled;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.categoryId,
    required this.parentCategoryId,
    required this.startTime,
    required this.endTime,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.capacity,
    required this.status,
    required this.inviteEnabled,
    required this.createdAt,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      teacherId: data['teacherId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      parentCategoryId: data['parentCategoryId'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      days: List<String>.from(data['days'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      capacity: data['capacity'] ?? 0,
      status: data['status'] ?? 'active',
      inviteEnabled: data['inviteEnabled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'categoryId': categoryId,
      'parentCategoryId': parentCategoryId,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'capacity': capacity,
      'status': status,
      'inviteEnabled': inviteEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
