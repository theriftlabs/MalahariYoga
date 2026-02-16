import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get top-level categories (parentId == null)
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

  // Get subcategories for a parent
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
}
