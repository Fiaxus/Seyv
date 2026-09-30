import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  Future<void> setName(String userId, String name) async {
    await _userDoc(userId).set({'name': name}, SetOptions(merge: true));
  }

  Future<String?> getName(String userId) async {
    final snapshot = await _userDoc(userId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return data['name'] as String?;
  }

  Future<void> deleteUser(String userId) async {
    await _userDoc(userId).delete();
  }
}