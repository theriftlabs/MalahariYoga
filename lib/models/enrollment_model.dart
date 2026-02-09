import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String classId;
  final String studentId;
  final DateTime joinedAt;
  final String status; // "active" | "dropped"

  EnrollmentModel({
    required this.id,
    required this.classId,
    required this.studentId,
    required this.joinedAt,
    required this.status,
  });

  factory EnrollmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      id: doc.id,
      classId: data['classId'] ?? '',
      studentId: data['studentId'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'studentId': studentId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'status': status,
    };
  }
}
