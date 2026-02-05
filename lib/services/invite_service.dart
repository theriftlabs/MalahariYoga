import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a short token (e.g., 5 chars)
  String _generateShortToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      5,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  Future<String> createInvite(String classId) async {
    final String token = _generateShortToken();
    final DateTime now = DateTime.now();
    final DateTime expires = now.add(const Duration(days: 7)); // Default 7 days expiry

    // Save to top-level 'invites' collection as requested
    // "No Nested Collections" rule -> top level
    await _firestore.collection('invites').doc(token).set({
      'token': token,
      'classId': classId,
      'expiresAt': Timestamp.fromDate(expires),
      'createdAt': Timestamp.fromDate(now),
      'active': true,
    });

    return token;
  }

  // Verify and retrieve classId from token
  Future<String?> verifyToken(String token) async {
    final doc = await _firestore.collection('invites').doc(token).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    final isActive = data['active'] ?? false;

    if (!isActive) return null;
    if (DateTime.now().isAfter(expiresAt)) return null;

    return data['classId'] as String?;
  }
}
