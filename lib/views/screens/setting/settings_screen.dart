part of 'package:stockmateapp/views/screens/screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: _buildAppBar(context, colors),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            // --- KARTU PROFIL ---
            _buildProfileCard(context, colors),
            const SizedBox(height: AppSpacing.xl),

            // --- PENGATURAN AKUN ---
            _buildSectionHeader('PENGATURAN AKUN', colors),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceL0,
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: colors.borderPrimary),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'Ganti Password',
                    subtitle: 'Ubah kata sandi keamanan Anda',
                    icon: Icons.lock_outline,
                    colors: colors,
                    onTap: () {
                      context.push('/settings/change-password');
                    },
                  ),
                  _buildDivider(colors),
                  _buildMenuItem(
                    title: 'Notifikasi',
                    subtitle: 'Atur peringatan stok dan laporan',
                    icon: Icons.notifications_none,
                    colors: colors,
                    onTap: () => context.push('/settings/notifications'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- PREFERENSI ---
            _buildSectionHeader('PREFERENSI', colors),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceL0,
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: colors.borderPrimary),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'Bahasa',
                    subtitle:
                        'Pilih bahasa aplikasi (${viewModel.language == 'id' ? 'Indonesia' : 'English'})',
                    icon: Icons.language,
                    colors: colors,
                    onTap: () => context.push('/settings/language'),
                  ),
                  _buildDivider(colors),
                  _buildThemeToggleItem(viewModel, colors),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- TOMBOL LOGOUT ---
            AppButton.secondary(
              text: 'Keluar dari Akun',
              icon: Icons.logout,
              isFullWidth: true,
              onPressed: () {
                context.go('/auth/login');
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  // --- HELPER WIDGETS ---
  AppBar _buildAppBar(BuildContext context, AppColors colors) {
    return AppBar(
      backgroundColor: colors.surfaceL0,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.inventory_2, color: colors.contentBrand),
          const SizedBox(width: AppSpacing.s),
          Text(
            'StockMate',
            style: AppTypography.headingL.copyWith(color: colors.contentBrand),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: colors.contentPrimary),
          onPressed: () => context.push('/notifications'),
        ),
        Container(
          margin: const EdgeInsets.only(
            right: AppSpacing.l,
            left: AppSpacing.xs,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.contentBrand,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Text(
            'WB',
            style: AppTypography.textXSSemibold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        children: [
          // Avatar dengan Icon Edit
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.backgroundDisabled,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.borderPrimary),
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: colors.contentSecondary,
                ), // Bisa diganti NetworkImage jika ada URL foto
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colors.contentBrand,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surfaceL0, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Wayan Budiana', style: AppTypography.headingL),
          Text(
            'admin@example.com',
            style: AppTypography.textSRegular.copyWith(
              color: colors.contentSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          // Badge Role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 12, color: Colors.teal[800]),
                const SizedBox(width: 4),
                Text(
                  'ADMIN GUDANG',
                  style: AppTypography.textXSSemibold.copyWith(
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton.secondary(
            text: 'Edit Profil',
            isFullWidth: true,
            onPressed: () => context.push('/settings/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTypography.textXSSemibold.copyWith(
            color: colors.contentSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.backgroundDisabled,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colors.contentBrand, size: 24),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.textMSemibold),
                  Text(
                    subtitle,
                    style: AppTypography.textSRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.contentSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem(SettingsViewModel viewModel, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.backgroundDisabled,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dark_mode_outlined,
              color: colors.contentBrand,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tema', style: AppTypography.textMSemibold),
                Text(
                  'Terang / Gelap / Sistem',
                  style: AppTypography.textSRegular.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Custom Segmented Control untuk Tema
          Container(
            decoration: BoxDecoration(
              color: colors.backgroundDisabled,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => viewModel.updateSetting('isDarkMode', false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: !viewModel.isDarkMode
                          ? colors.surfaceL0
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: !viewModel.isDarkMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      'Terang',
                      style: AppTypography.textXSSemibold.copyWith(
                        color: !viewModel.isDarkMode
                            ? colors.contentBrand
                            : colors.contentSecondary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => viewModel.updateSetting('isDarkMode', true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: viewModel.isDarkMode
                          ? colors.surfaceL0
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: viewModel.isDarkMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      'Gelap',
                      style: AppTypography.textXSSemibold.copyWith(
                        color: viewModel.isDarkMode
                            ? colors.contentBrand
                            : colors.contentSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColors colors) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
    child: Divider(height: 1, color: colors.borderPrimary),
  );
}
