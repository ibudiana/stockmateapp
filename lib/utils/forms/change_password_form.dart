part of 'forms.dart';

class ChangePasswordForm {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Getter otomatis untuk validasi real-time di UI
  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasLetterAndNumber =>
      newPasswordController.text.contains(RegExp(r'[a-zA-Z]')) &&
      newPasswordController.text.contains(RegExp(r'[0-9]'));

  bool validate(Function(String) onError) {
    if (oldPasswordController.text.isEmpty) {
      onError("Kata sandi lama wajib diisi.");
      return false;
    }
    if (newPasswordController.text.isEmpty) {
      onError("Kata sandi baru wajib diisi.");
      return false;
    }
    if (!hasMinLength || !hasLetterAndNumber) {
      onError("Kata sandi baru tidak memenuhi persyaratan keamanan.");
      return false;
    }
    if (confirmPasswordController.text != newPasswordController.text) {
      onError("Konfirmasi kata sandi tidak cocok.");
      return false;
    }
    return true;
  }

  // Membersihkan inputan setelah berhasil atau saat keluar halaman
  void clear() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
