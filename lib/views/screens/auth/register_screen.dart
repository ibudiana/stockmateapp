part of 'package:stockmateapp/views/screens/screens.dart';

// Ubah menjadi StatefulWidget untuk memegang FormKey
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Tambahkan FormKey untuk validasi
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false; // State untuk checkbox

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.xl,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl3,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundPrimary,
                border: Border.all(
                  color: colors.borderPrimary,
                  width: AppBorder.widthXs,
                ),
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              // BUNGKUS DENGAN FORM
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          style: AppTypography.headingM.copyWith(
                            color: colors.contentBrand,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    Text(
                      'Buat Akun Baru',
                      style: AppTypography.headingL.copyWith(
                        color: colors.contentPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Silakan lengkapi formulir di bawah untuk\nmemulai.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textMRegular.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl3),

                    AppTextInput.text(
                      label: 'Nama Lengkap',
                      hint: 'Contoh: Budi Santoso',
                      controller: viewModel.nameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),

                    AppTextInput.text(
                      label: 'Username',
                      hint: 'admin',
                      controller: viewModel.usernameController,
                      prefixIcon: Icons.account_circle_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        if (value.length < 4) {
                          return 'Username minimal 4 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),

                    AppTextInput.email(
                      label: 'Email',
                      hint: 'admin@example.com',
                      controller: viewModel.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        // Simple regex validasi email
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),

                    AppTextInput.password(
                      label: 'Password',
                      hint: '••••••••',
                      controller: viewModel.passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.l),

                    AppTextInput.password(
                      label: 'Konfirmasi Password',
                      hint: '••••••••',
                      controller: viewModel.confirmPasswordController,
                      prefixIcon: Icons.lock_clock_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != viewModel.passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    // --- Terms Checkbox ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _isTermsAccepted,
                            onChanged: (bool? value) {
                              setState(() {
                                _isTermsAccepted = value ?? false;
                              });
                            },
                            activeColor: colors.backgroundBrand,
                            side: BorderSide(color: colors.contentPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.textSRegular.copyWith(
                                color: colors.contentPrimary,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(text: 'Saya setuju dengan '),
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: AppTypography.textSRegular.copyWith(
                                    color: colors.contentLink,
                                  ),
                                ),
                                const TextSpan(text: ' serta\n'),
                                TextSpan(
                                  text: 'Kebijakan Privasi',
                                  style: AppTypography.textSRegular.copyWith(
                                    color: colors.contentLink,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl3),

                    // --- BUTTON COMPONENT ---
                    // ... (Pastikan meng-import app_snackbar.dart)
                    // import 'package:stockmateapp/components/app_snackbar.dart';
                    AppButton.primary(
                      text: 'Daftar Sekarang',
                      icon: Icons.arrow_forward,
                      isFullWidth: true,
                      isLoading: viewModel.state.status == AuthStatus.loading,
                      onPressed: () async {
                        // 1. Validasi Form terlebih dahulu
                        if (!_formKey.currentState!.validate()) {
                          return; // Berhenti jika ada field yang error
                        }

                        // 2. Validasi Checkbox menggunakan Global Snackbar (Notice)
                        if (!_isTermsAccepted) {
                          AppSnackbar.showNotice(
                            context,
                            title: 'Perhatian',
                            message:
                                'Silakan setujui Syarat & Ketentuan terlebih dahulu.',
                          );
                          return;
                        }

                        // 3. Eksekusi fungsi di ViewModel
                        await context.read<AuthViewModel>().register();
                        final state = context.read<AuthViewModel>().state;

                        // 4. Handle Success menggunakan Global Snackbar
                        if (state.status == AuthStatus.authenticated &&
                            context.mounted) {
                          AppSnackbar.showSuccess(
                            context,
                            title: 'Berhasil',
                            message: 'Akun Anda telah berhasil dibuat!',
                          );

                          // Lanjutkan navigasi
                          // Navigator.pushReplacementNamed(context, '/home');
                        }

                        // Opsional: Handle Error menggunakan Global Snackbar jika belum di-handle di ViewModel
                        if (state.status == AuthStatus.error &&
                            context.mounted) {
                          AppSnackbar.showError(
                            context,
                            title: 'Gagal',
                            message:
                                state.message ??
                                'Terjadi kesalahan saat registrasi.',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl4),

                    // --- LINK BUTTON COMPONENT ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: AppTypography.textMRegular.copyWith(
                            color: colors.contentPrimary,
                          ),
                        ),
                        AppButton.link(
                          text: 'Masuk di sini',
                          onPressed: () {
                            // Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
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
}
