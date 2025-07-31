import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  Future<void> loadCurrentUser() async {
    try {
      _isLoading = true;
      _currentUser = await _authService.getCurrentUserData();
    } catch (e) {
      print('Error loading current user: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshUser() async {
    await loadCurrentUser();
  }

  void clearUser() {
    _currentUser = null;
  }

  String getDisplayName() {
    if (_currentUser == null) return 'User';
    
    if (_currentUser!.isStudent) {
      return _currentUser!.anonymousName ?? 'Student';
    } else {
      return _currentUser!.realName;
    }
  }

  int? getCurrentUserId() {
    return _currentUser?.id;
  }

  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }
}
