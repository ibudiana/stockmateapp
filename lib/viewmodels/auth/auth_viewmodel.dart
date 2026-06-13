part of 'auth.dart';

// --- 3. VIEWMODEL UTAMA ---
class AuthViewModel extends ChangeNotifier {
  final AuthRepositoryImpl repository;

  // Pasang Form di sini
  final loginForm = LoginForm();
  final registerForm = RegisterForm();

  AuthViewModel({required this.repository});

  AuthState _state = const AuthState();
  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // Helper untuk menampilkan error dari Form
  void _showError(String message) {
    _setState(_state.copyWith(status: AuthStatus.error, message: message));
  }

  // --- FUNGSI LOGIN ---
  Future<void> login() async {
    if (!loginForm.validate(_showError)) return;

    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      final user = await repository.login(
        loginForm.emailController.text.trim(),
        loginForm.passwordController.text,
      );

      _setState(
        _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: "Login berhasil.",
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
    }
  }

  // --- FUNGSI REGISTER ---
  Future<void> register() async {
    if (!registerForm.validate(_showError)) return;

    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      final user = await repository.registerAndSync(
        registerForm.nameController.text.trim(),
        registerForm.usernameController.text.trim(),
        registerForm.emailController.text.trim(),
        registerForm.passwordController.text,
      );

      _setState(
        _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: "Registrasi berhasil.",
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Terjadi kesalahan sistem. Silakan coba lagi.";

      if (e.code == 'email-already-in-use') {
        errorMessage =
            "Email ini sudah terdaftar. Silakan gunakan email lain atau coba masuk.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      } else if (e.code == 'weak-password') {
        errorMessage =
            "Password terlalu lemah. Gunakan kombinasi yang lebih kuat.";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "Registrasi email belum diaktifkan.";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Gagal terhubung ke internet. Periksa koneksi Anda.";
      }

      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
    } catch (e) {
      final errorMessage = DatabaseErrorMapper.map(e);
      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
    }
  }

  void resetState() {
    _setState(const AuthState());
  }

  @override
  void dispose() {
    loginForm.dispose();
    registerForm.dispose();
    super.dispose();
  }
}
