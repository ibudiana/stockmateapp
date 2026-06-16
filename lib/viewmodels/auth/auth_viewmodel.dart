part of 'auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepositoryImpl repository;

  // Pasang Form di sini
  final loginForm = LoginForm();
  final registerForm = RegisterForm();
  final resetPasswordForm = ResetPasswordForm();
  final changePasswordForm = ChangePasswordForm();
  final editProfileForm = EditProfileForm();

  AuthViewModel({required this.repository}) {
    _loadSessionUser();
  }

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

  // --- FUNGSI AUTO LOAD USER ---
  Future<void> _loadSessionUser() async {
    if (SessionService.isLoggedInSync) {
      final userId = SessionService.currentUserId!;
      try {
        final users = await repository.getAllUsersLocally();
        final user = users.firstWhere((u) => u.id == userId);
        _setState(
          _state.copyWith(status: AuthStatus.authenticated, user: user),
        );
      } catch (e) {
        resetState(); // Jika user tidak ditemukan di SQLite, bersihkan sesi
      }
    }
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', user.id);

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

  //  --- FUNGSI RESET PASSWORD ---
  Future<void> resetPassword() async {
    if (!resetPasswordForm.validate(_showError)) return;

    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      await repository.resetPassword(
        resetPasswordForm.emailController.text.trim(),
      );
      _setState(
        _state.copyWith(
          status: AuthStatus.success,
          message: "Instruksi reset password telah dikirim ke email Anda.",
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (!changePasswordForm.validate(_showError)) return false;

    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      // 1. Pastikan ada user yang sedang login dari _state
      final currentUser = _state.user;
      if (currentUser == null) {
        throw Exception('Tidak ada sesi login aktif.');
      }

      // 2. Verifikasi Password Lama
      // Asumsi AuthRepositoryImpl memiliki fungsi getAllUsersLocally
      final userList = await repository.getAllUsersLocally();
      final userInDb = userList.firstWhere(
        (u) => u.id == currentUser.id,
        orElse: () =>
            throw Exception('Data pengguna tidak ditemukan di sistem.'),
      );

      if (userInDb.password != oldPassword) {
        throw Exception('Kata sandi lama yang Anda masukkan salah.');
      }

      // 3. Simpan Password Baru
      final updatedUser = userInDb.copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );

      // Update ke SQLite melalui repository
      await repository.updateUserLocally(updatedUser);

      // Update sesi aktif & kembalikan status authenticated dengan pesan sukses
      _setState(
        _state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          message: "Kata sandi berhasil diperbarui.",
        ),
      );
      return true; // Berhasil
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      // Set state ke error agar UI bisa menangkap pesannya
      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
      return false; // Gagal
    }
  }

  Future<bool> updateProfile() async {
    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      final currentUser = _state.user;
      if (currentUser == null) {
        throw Exception('Tidak ada sesi login aktif. Silakan login ulang.');
      }

      final updatedUser = currentUser.copyWith(
        name: editProfileForm.nameController.text.trim(),
        email: editProfileForm.emailController.text.trim(),
        phone: editProfileForm.phoneController.text.trim(),
        profilePictureUrl: editProfileForm.imagePath,
        updatedAt: DateTime.now(),
      );

      await repository.updateUserLocally(updatedUser);

      // Perbarui sesi aktif
      _setState(
        _state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
          message: "Profil berhasil diperbarui.",
        ),
      );
      return true; // Berhasil
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(
        _state.copyWith(status: AuthStatus.error, message: errorMessage),
      );
      return false; // Gagal
    }
  }

  // --- FUNGSI UBAH FOTO PROFIL ---
  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Buka galeri HP pengguna
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        editProfileForm.imagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      _setState(
        _state.copyWith(
          status: AuthStatus.error,
          message: "Gagal memuat foto: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> resetState() async {
    await SessionService.clearSession();
    _setState(const AuthState());
  }

  @override
  void dispose() {
    loginForm.dispose();
    registerForm.dispose();
    resetPasswordForm.dispose();
    changePasswordForm.dispose();
    super.dispose();
  }
}
