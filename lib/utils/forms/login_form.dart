part of 'forms.dart';

class LoginForm {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool validate(Function(String) onError) {
    if (emailController.text.trim().isEmpty) {
      onError("Email tidak boleh kosong.");
      return false;
    }

    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      onError("Format email tidak valid.");
      return false;
    }

    if (passwordController.text.isEmpty) {
      onError("Kata sandi tidak boleh kosong.");
      return false;
    }
    return true;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
