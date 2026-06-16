part of 'package:stockmateapp/views/screens/screens.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late EditProfileForm _form;

  // Controller lokal khusus untuk field Read-Only
  final _roleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authVM = context.read<AuthViewModel>();
    _form = authVM.editProfileForm;

    // Isi kolom input dengan data pengguna yang sedang login
    final currentUser = authVM.state.user;
    if (currentUser != null) {
      _form.nameController.text = currentUser.name;
      _form.emailController.text = currentUser.email;

      // Ambil role dari UserModel (sesuaikan jika logic penamaan role Anda berbeda)
      _roleCtrl.text = currentUser.role.name.toUpperCase();

      // Jika nomor telepon tersimpan di UserModel, isi di sini
      // _form.phoneController.text = currentUser.phone ?? '';
    }
  }

  void _submitForm() async {
    // 1. Validasi kerangka UI
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi Logika Form
    bool isValid = _form.validate((errorMsg) {
      AppSnackbar.showError(context, message: errorMsg);
    });
    if (!isValid) return;

    // 3. Eksekusi ke SQLite via ViewModel
    final authVM = context.read<AuthViewModel>();
    final success = await authVM.updateProfile();

    if (success && mounted) {
      AppSnackbar.showSuccess(
        context,
        message: authVM.state.message ?? 'Profil berhasil diperbarui!',
      );
      Navigator.pop(context); // Kembali ke menu pengaturan
    } else if (mounted) {
      AppSnackbar.showError(
        context,
        message: authVM.state.message ?? 'Gagal memperbarui profil',
      );
    }
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isLoading = viewModel.state.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: colors.surfaceL0,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.contentBrand),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTypography.headingM.copyWith(color: colors.contentBrand),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.l),
              // --- FOTO PROFIL ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colors.backgroundDisabled,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.borderPrimary),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: colors.contentSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.contentBrand,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colors.surfaceL0,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Ubah Foto',
                      style: AppTypography.textMSemibold.copyWith(
                        color: colors.contentBrand,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- FORM ---
              AppTextInput.text(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama Anda',
                controller: _form.nameController,
              ),
              const SizedBox(height: AppSpacing.l),
              AppTextInput.text(
                label: 'Email',
                hint: 'Masukkan email',
                controller: _form.emailController,
              ),
              const SizedBox(height: AppSpacing.l),

              // Read-only field untuk peran
              AbsorbPointer(
                child: AppTextInput.text(
                  label: 'Jabatan/Peran',
                  hint: '',
                  controller: _roleCtrl,
                  suffixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Hubungi IT Support untuk mengubah peran Anda.',
                    style: AppTypography.textXSRegular.copyWith(
                      color: colors.contentSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Custom Phone Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nomor Telepon',
                  style: AppTypography.textSRegular.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceL0,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(color: colors.borderPrimary),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colors.backgroundDisabled,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.m),
                        ),
                        border: Border(
                          right: BorderSide(color: colors.borderPrimary),
                        ),
                      ),
                      child: Text(
                        '+62',
                        style: AppTypography.textMRegular.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _form.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: AppTypography.textMRegular,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl * 1.5),

              // --- TOMBOL ---
              AppButton.primary(
                text: 'Simpan Perubahan',
                isFullWidth: true,
                isLoading: isLoading,
                onPressed: _submitForm,
              ),
              const SizedBox(height: AppSpacing.m),
              AppButton.secondary(
                text: 'Batal',
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
