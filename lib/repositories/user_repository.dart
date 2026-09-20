import '../services/user_service.dart';

class UserRepository {
  final UserService _service = UserService();

  Future<void> setName(String userId, String name) {
    return _service.setName(userId, name);
  }

  Future<String?> getName(String userId) {
    return _service.getName(userId);
  }
}