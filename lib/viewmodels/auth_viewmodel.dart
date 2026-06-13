import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/repositories/auth_repository.dart';
import 'package:stockmateapp/utils/exceptions/database_error_mapper.dart';

enum AuthStatus { idle, loading, authenticated, success, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? message;

  const AuthState({this.status = AuthStatus.idle, this.user, this.message});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? message}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepositoryImpl repository;

  AuthViewModel({required this.repository});

  AuthState _state = const AuthState();

  AuthState get state => _state;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  bool validateRegisterForm() {
    if (nameController.text.trim().isEmpty) {
      _setState(
        _state.copyWith(
          status: AuthStatus.error,
          message: "Nama tidak boleh kosong.",
        ),
      );
      return false;
    }

    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      _setState(
        _state.copyWith(
          status: AuthStatus.error,
          message: "Format email tidak valid.",
        ),
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      _setState(
        _state.copyWith(
          status: AuthStatus.error,
          message: "Kata sandi minimal 6 karakter.",
        ),
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _setState(
        _state.copyWith(
          status: AuthStatus.error,
          message: "Konfirmasi kata sandi tidak cocok.",
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> register() async {
    if (!validateRegisterForm()) {
      return;
    }

    _setState(_state.copyWith(status: AuthStatus.loading, message: null));

    try {
      final user = await repository.registerAndSync(
        nameController.text.trim(),
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      _setState(
        _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          message: "Registrasi berhasil.",
        ),
      );
    } on FirebaseAuthException catch (e) {
      // 1. Tangkap spesifik error dari Firebase
      String errorMessage = "Terjadi kesalahan sistem. Silakan coba lagi.";

      // 2. Petakan kode error Firebase ke pesan UI yang ramah
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
