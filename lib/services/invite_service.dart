import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<String> createInvite(String classId) async {
    String token = _uuid.v4();
    
    await _firestore.collection('invites').doc(token).set({
      'classId': classId,
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'usedCount': 0,
      'active': true,
    });
    
    return token;
  }
}
