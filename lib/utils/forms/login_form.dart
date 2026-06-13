part of 'forms.dart';

class LoginForm {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool validate(Function(String) onError) {
    if (emailController.text.trim().isEmpty) {
      onError("Email tidak boleh kosong.");
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
