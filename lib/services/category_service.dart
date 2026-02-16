import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> getTopLevelCategories() {
    return _firestore
        .collection('categories')
        .where('parentId', isNull: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<CategoryModel>> getSubCategories(String parentId) {
    return _firestore
        .collection('categories')
        .where('parentId', isEqualTo: parentId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Create a new category
  Future<String> createCategory(String name) async {
    final docRef = _firestore.collection('categories').doc();
    await docRef.set({
      'id': docRef.id,
      'name': name,
      'parentId': null, // Top level by default
      'order': DateTime.now().millisecondsSinceEpoch,
    });
    return docRef.id;
  }
}
