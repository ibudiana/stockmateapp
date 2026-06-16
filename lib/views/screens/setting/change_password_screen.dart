part of 'package:stockmateapp/views/screens/screens.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Gunakan controller lokal agar inputan mengunci sempurna dan aman dari bug rebuild
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _hasMinLength = false;
  bool _hasLetterAndNumber = false;
  late ChangePasswordForm _form;

  @override
  void initState() {
    super.initState();
    _form = context.read<AuthViewModel>().changePasswordForm;

    // Dengarkan ketikan di controller lokal untuk indikator keamanan real-time
    _newPasswordCtrl.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _hasMinLength = _newPasswordCtrl.text.length >= 8;
      _hasLetterAndNumber =
          _newPasswordCtrl.text.contains(RegExp(r'[a-zA-Z]')) &&
          _newPasswordCtrl.text.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void dispose() {
    _newPasswordCtrl.removeListener(_onPasswordChanged);
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _form.clear();
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
        backgroundColor: colors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.contentBrand),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl3,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceL0,
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: colors.borderPrimary),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: colors.contentBrand,
                          size: 28,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          'StockMate',
                          style: AppTypography.headingL.copyWith(
                            color: colors.contentBrand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl2),
                    Text('Keamanan Akun', style: AppTypography.headingL),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Silakan masukkan kata sandi baru Anda untuk melanjutkan akses ke sistem Inventory Pro.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textMRegular.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl3),

                    // --- INPUT KATA SANDI LAMA (Menggunakan Controller Lokal) ---
                    AppTextInput.password(
                      label: 'KATA SANDI LAMA',
                      controller: _oldPasswordCtrl,
                      hint: 'admin1234',
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- INPUT KATA SANDI BARU (Menggunakan Controller Lokal) ---
                    AppTextInput.password(
                      label: 'KATA SANDI BARU',
                      controller: _newPasswordCtrl,
                      hint: 'admin1234',
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- INPUT KONFIRMASI (Menggunakan Controller Lokal) ---
                    AppTextInput.password(
                      label: 'KONFIRMASI KATA SANDI BARU',
                      controller: _confirmPasswordCtrl,
                      hint: 'admin1234',
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // --- KOTAK PERSYARATAN KEAMANAN ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.l),
                      decoration: BoxDecoration(
                        color: colors.contentBrand.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppRadius.m),
                        border: Border.all(
                          color: colors.contentBrand.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: colors.contentBrand,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Text(
                                'Persyaratan Keamanan:',
                                style: AppTypography.textMSemibold.copyWith(
                                  color: colors.contentBrand,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.m),
                          _buildRequirementItem(
                            'Minimal 8 karakter',
                            _hasMinLength,
                            colors,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _buildRequirementItem(
                            'Kombinasi huruf dan angka',
                            _hasLetterAndNumber,
                            colors,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    // --- TOMBOL SIMPAN ---
                    AppButton.primary(
                      text: 'Simpan Kata Sandi',
                      icon: Icons.check_circle_outline,
                      isFullWidth: true,
                      isLoading: isLoading,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        // 2. SINKRONISASI: Salin isi text dari lokal ke form di ViewModel sebelum divalidasi
                        _form.oldPasswordController.text =
                            _oldPasswordCtrl.text;
                        _form.newPasswordController.text =
                            _newPasswordCtrl.text;
                        _form.confirmPasswordController.text =
                            _confirmPasswordCtrl.text;

                        // 3. Jalankan validasi logika form
                        bool isValid = _form.validate((errorMsg) {
                          AppSnackbar.showError(context, message: errorMsg);
                        });
                        if (!isValid) return;

                        // 4. Eksekusi simpan ke SQLite
                        final success = await viewModel.changePassword(
                          _form.oldPasswordController.text,
                          _form.newPasswordController.text,
                        );

                        if (success && context.mounted) {
                          AppSnackbar.showSuccess(
                            context,
                            message:
                                viewModel.state.message ??
                                'Kata sandi berhasil diperbarui!',
                          );
                          _oldPasswordCtrl.clear();
                          _newPasswordCtrl.clear();
                          _confirmPasswordCtrl.clear();
                          context.go("/settings");
                        } else if (context.mounted) {
                          AppSnackbar.showError(
                            context,
                            message:
                                viewModel.state.message ??
                                'Gagal mengubah password',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet, AppColors colors) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.teal : colors.contentSecondary,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          text,
          style: AppTypography.textSRegular.copyWith(
            color: isMet ? colors.contentPrimary : colors.contentSecondary,
          ),
        ),
      ],
    );
  }
}
