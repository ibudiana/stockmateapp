part of 'forms.dart';

class ResetPasswordForm {
  final emailController = TextEditingController();

  bool validate(Function(String) onError) {
    if (emailController.text.trim().isEmpty) {
      onError("Email tidak boleh kosong.");
      return false;
    }
    return true;
  }

  void dispose() {
    emailController.dispose();
  }
}
