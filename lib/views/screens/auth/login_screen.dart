part of 'package:stockmateapp/views/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Box
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: colors.backgroundBrand,
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: colors.contentPrimaryInverse,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    Text('Selamat Datang', style: AppTypography.headingL),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Silahkan login untuk melanjutkan',
                      style: AppTypography.textMRegular.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl3),

                    // Input Email
                    AppTextInput.email(
                      label: 'Email',
                      hint: 'nama@email.com',
                      controller: viewModel.loginForm.emailController,
                      validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Input Password
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASSWORD',
                              style: AppTypography.textXSSemibold,
                            ),
                            AppButton.link(
                              text: 'Lupa password?',
                              onPressed: () {}, // Implementasi lupa password
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AppTextInput.password(
                          label: '', // Kosongkan karena label manual di atas
                          hint: '••••••••',
                          controller: viewModel.loginForm.passwordController,
                          validator: (v) => v!.length < 6
                              ? 'Password minimal 6 karakter'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl2),

                    // Submit Button
                    AppButton.primary(
                      text: 'Sign In',
                      icon: Icons.login,
                      isFullWidth: true,
                      isLoading: viewModel.state.status == AuthStatus.loading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await viewModel.login();
                          if (viewModel.state.status ==
                                  AuthStatus.authenticated &&
                              context.mounted) {
                            AppSnackbar.showSuccess(
                              context,
                              message: 'Selamat datang kembali!',
                            );
                            // Navigasi ke dashboard setelah login sukses
                            // context.go('/home');
                          } else if (viewModel.state.status ==
                                  AuthStatus.error &&
                              context.mounted) {
                            AppSnackbar.showError(
                              context,
                              message: viewModel.state.message!,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl3),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: AppTypography.textMRegular,
                        ),
                        AppButton.link(
                          text: 'Daftar',
                          onPressed: () {
                            context.go('/auth/register');
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
