part of 'forms.dart';

class RegisterForm {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool validate(Function(String) onError) {
    if (nameController.text.trim().isEmpty) {
      onError("Nama tidak boleh kosong.");
      return false;
    }
    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      onError("Format email tidak valid.");
      return false;
    }
    if (passwordController.text.length < 6) {
      onError("Kata sandi minimal 6 karakter.");
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      onError("Konfirmasi kata sandi tidak cocok.");
      return false;
    }
    return true;
  }

  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
