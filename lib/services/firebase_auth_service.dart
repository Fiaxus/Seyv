import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> reauthenticate({required String password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) return;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.delete();
  }

  Future<void> updateEmail({required String newEmail}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.verifyBeforeUpdateEmail(newEmail);
  }
}