import '../services/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();

  Future<void> signUp({required String email, required String password}) async {
    await _authService.signUp(email: email, password: password);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> reauthenticate({required String password}) async {
    await _authService.reauthenticate(password: password);
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }

  Future<void> updateEmail({required String newEmail}) async {
    await _authService.updateEmail(newEmail: newEmail);
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _authService.updatePassword(newPassword: newPassword);
  }
}