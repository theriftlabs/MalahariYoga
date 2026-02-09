import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? parentId; // Null if top-level
  final int order;
  final String createdBy;
  final bool active;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.order,
    required this.createdBy,
    required this.active,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      parentId: data['parentId'],
      order: data['order'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parentId': parentId,
      'order': order,
      'createdBy': createdBy,
      'active': active,
    };
  }
}
