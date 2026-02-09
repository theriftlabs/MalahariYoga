import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ClassModel>> getClassesByCategory(String categoryId) {
    return _firestore
        .collection('classes')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ClassModel>> getClassesForTeacher(String teacherId) {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromFirestore(doc))
            .toList());
  }

  Future<void> createClass({
    required String title,
    required String description,
    required String teacherId,
    required String categoryId,
    required String parentCategoryId,
    required String startTime,
    required String endTime,
    required List<String> days,
    required DateTime startDate,
    required DateTime endDate,
    required int capacity,
    required bool inviteEnabled,
  }) async {
    await _firestore.collection('classes').add({
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
      'status': 'active',
      'inviteEnabled': inviteEnabled,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
