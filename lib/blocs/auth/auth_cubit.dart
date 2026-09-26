import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/auth_error_translator.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthCubit() : super(AuthInitial());

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(translateAuthError(e)));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(translateAuthError(e)));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(translateAuthError(e)));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authRepository.sendPasswordResetEmail(email: email);
  }

  Future<void> reauthenticate({required String password}) {
    return _authRepository.reauthenticate(password: password);
  }

  Future<void> deleteAccount() {
    return _authRepository.deleteAccount();
  }

  Future<void> updateEmail({required String newEmail}) {
    return _authRepository.updateEmail(newEmail: newEmail);
  }

  Future<void> updatePassword({required String newPassword}) {
    return _authRepository.updatePassword(newPassword: newPassword);
  }
}