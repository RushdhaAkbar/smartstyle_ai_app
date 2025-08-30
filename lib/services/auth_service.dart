class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<String> login(String email, String password) async {
    // Mock for test
    if (email == 'test@user.com' && password == 'password123') {
      return 'mock_token_abc';
    } else {
      throw Exception('Invalid credentials');
    }
  }
}