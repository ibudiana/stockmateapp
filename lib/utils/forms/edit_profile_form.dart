part of 'forms.dart';

class EditProfileForm {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String? imagePath;

  bool validate(Function(String) onError) {
    if (nameController.text.trim().isEmpty) {
      onError("Nama lengkap tidak boleh kosong.");
      return false;
    }

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

    // Catatan: Jika ada validasi nomor telepon khusus, bisa ditambahkan di sini

    return true;
  }

  // Membersihkan memori saat keluar
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    imagePath = null;
  }
}
