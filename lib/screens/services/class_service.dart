import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/class_model.dart';

class ClassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create a new class
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
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();

    final classModel = ClassModel(
      id: id,
      title: title,
      description: description,
      teacherId: teacherId,
      categoryId: categoryId,
      parentCategoryId: parentCategoryId,
      startTime: startTime,
      endTime: endTime,
      days: days,
      startDate: startDate,
      endDate: endDate,
      capacity: capacity,
      status: 'active',
      inviteEnabled: inviteEnabled,
      createdAt: now,
    );

    // Write to generic top-level classes collection
    await _firestore.collection('classes').doc(id).set(classModel.toMap());
  }

  // Generic query method
  Stream<List<ClassModel>> getClassesForTeacher(String teacherId) {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromFirestore(doc))
            .toList());
  }

  // Category specific query
  Stream<List<ClassModel>> getClassesByCategory(String categoryId) {
    return _firestore
        .collection('classes')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClassModel.fromFirestore(doc))
            .toList());
  }
}
