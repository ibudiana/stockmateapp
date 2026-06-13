part of 'package:stockmateapp/views/screens/screens.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
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
                border: Border.all(color: colors.borderPrimary),
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Logo
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

                  // Placeholder Gambar (Ganti dengan asset Anda nanti)
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.backgroundSelected,
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 60,
                      color: colors.contentBrand,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl2),

                  Text('Lupa Kata Sandi?', style: AppTypography.headingL),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Masukkan alamat email Anda yang terdaftar\nuntuk menerima instruksi pemulihan dan kode verifikasi.',
                    textAlign: TextAlign.center,
                    style: AppTypography.textMRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl3),

                  AppTextInput.email(
                    label: 'ALAMAT EMAIL',
                    hint: 'nama@perusahaan.com',
                    controller: viewModel.resetPasswordForm.emailController,
                  ),
                  const SizedBox(height: AppSpacing.xl3),

                  AppButton.primary(
                    text: 'Kirim Kode',
                    icon: Icons.arrow_forward,
                    isFullWidth: true,
                    isLoading: viewModel.state.status == AuthStatus.loading,
                    onPressed: () async {
                      await context.read<AuthViewModel>().resetPassword();

                      final state = context.read<AuthViewModel>().state;

                      if (!context.mounted) return;

                      if (state.status == AuthStatus.success) {
                        AppSnackbar.showSuccess(
                          context,
                          title: 'Berhasil',
                          message:
                              'Instruksi reset password telah dikirim ke email Anda.',
                        );

                        context.go('/auth/login');
                      } else {
                        AppSnackbar.showError(
                          context,
                          title: 'Gagal',
                          message:
                              state.message ??
                              'Gagal mengirim email reset password.',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton.link(
                    text: 'Kembali ke Login',
                    icon: Icons.arrow_back,
                    onPressed: () => context.go('/auth/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
