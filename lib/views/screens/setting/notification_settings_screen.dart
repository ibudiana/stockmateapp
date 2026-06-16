part of 'package:stockmateapp/views/screens/screens.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: colors.surfaceL0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.contentBrand),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: colors.contentBrand),
            const SizedBox(width: AppSpacing.s),
            Text(
              'StockMate',
              style: AppTypography.headingL.copyWith(
                color: colors.contentBrand,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: colors.contentPrimary),
            onPressed: () {},
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            // --- SECTION 1: PERINGATAN STOK ---
            _buildSettingSection(
              title: 'PERINGATAN STOK',
              colors: colors,
              children: [
                _buildToggleItem(
                  title: 'Stok Menipis',
                  subtitle: 'Peringatkan jika stok di bawah batas minimum',
                  value: viewModel.notifyLowStock,
                  onChanged: (v) =>
                      viewModel.updateSetting('notifyLowStock', v),
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildToggleItem(
                  title: 'Stok Habis',
                  subtitle: 'Notifikasi instan saat produk tidak tersedia',
                  value: viewModel.notifyOutOfStock,
                  onChanged: (v) =>
                      viewModel.updateSetting('notifyOutOfStock', v),
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildToggleItem(
                  title: 'Produk Kedaluwarsa',
                  subtitle: 'Peringatan 30 hari sebelum tanggal kedaluwarsa',
                  value: viewModel.notifyExpiry,
                  onChanged: (v) => viewModel.updateSetting('notifyExpiry', v),
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),

            // --- SECTION 2: LAPORAN & AKTIVITAS ---
            _buildSettingSection(
              title: 'LAPORAN & AKTIVITAS',
              colors: colors,
              children: [
                _buildToggleItem(
                  title: 'Ringkasan Harian',
                  subtitle: 'Kirim laporan stok setiap sore',
                  value: viewModel.notifyDailySummary,
                  onChanged: (v) =>
                      viewModel.updateSetting('notifyDailySummary', v),
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildToggleItem(
                  title: 'Aktivitas Gudang',
                  subtitle: 'Notifikasi untuk setiap barang masuk/keluar',
                  value: viewModel.notifyActivity,
                  onChanged: (v) =>
                      viewModel.updateSetting('notifyActivity', v),
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),

            // --- SECTION 3: METODE NOTIFIKASI ---
            _buildSettingSection(
              title: 'METODE NOTIFIKASI',
              colors: colors,
              children: [
                _buildIconToggleItem(
                  icon: Icons.notifications_none,
                  title: 'Push Notification',
                  value: viewModel.methodPush,
                  onChanged: (v) => viewModel.updateSetting('methodPush', v),
                  colors: colors,
                ),
                _buildDivider(colors),
                _buildIconToggleItem(
                  icon: Icons.mail_outline,
                  title: 'Email',
                  value: viewModel.methodEmail,
                  onChanged: (v) => viewModel.updateSetting('methodEmail', v),
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- BLUE BANNER PROMO ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.contentBrand,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pantau Inventaris Tanpa Ribet',
                          style: AppTypography.textMSemibold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Sistem akan otomatis memberikan laporan berkala sesuai pengaturan notifikasi Anda.',
                          style: AppTypography.textSRegular.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 64,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
    required AppColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            decoration: BoxDecoration(
              color: colors.backgroundDisabled,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.m),
              ),
              border: Border(bottom: BorderSide(color: colors.borderPrimary)),
            ),
            child: Text(
              title,
              style: AppTypography.textXSSemibold.copyWith(
                color: colors.contentSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textMSemibold),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.textSRegular.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: colors.contentBrand,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colors.borderPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildIconToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Icon(icon, color: colors.contentPrimary),
          const SizedBox(width: AppSpacing.m),
          Expanded(child: Text(title, style: AppTypography.textMSemibold)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: colors.contentBrand,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Divider(height: 1, color: colors.borderPrimary),
    );
  }
}
