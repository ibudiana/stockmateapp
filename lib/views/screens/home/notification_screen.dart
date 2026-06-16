part of 'package:stockmateapp/views/screens/screens.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

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
          'Notifikasi',
          style: AppTypography.headingM.copyWith(color: colors.contentBrand),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.contentPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.generateNotifications(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TERBARU ---
                    if (viewModel.recentNotifications.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Terbaru', style: AppTypography.headingM),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.contentBrand,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${viewModel.recentNotifications.length} BARU',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // SOLUSI: Tambahkan .toList() di sini!
                      ...viewModel.recentNotifications
                          .map((notif) => _buildNotificationCard(notif, colors))
                          .toList(),

                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // --- MINGGU INI (OLDER) ---
                    if (viewModel.olderNotifications.isNotEmpty) ...[
                      Text('Minggu Ini', style: AppTypography.headingM),
                      const SizedBox(height: AppSpacing.m),

                      // SOLUSI: Tambahkan .toList() di sini juga!
                      ...viewModel.olderNotifications
                          .map((notif) => _buildNotificationCard(notif, colors))
                          .toList(),
                    ],

                    // JIKA KOSONG
                    if (viewModel.recentNotifications.isEmpty &&
                        viewModel.olderNotifications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Belum ada notifikasi.',
                            style: AppTypography.textMRegular.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, AppColors colors) {
    // Helper format waktu
    final now = DateTime.now();
    final isToday = notif.time.day == now.day && notif.time.month == now.month;
    final timeStr = isToday
        ? "${notif.time.hour.toString().padLeft(2, '0')}:${notif.time.minute.toString().padLeft(2, '0')}"
        : "${notif.time.day}/${notif.time.month} ${notif.time.hour.toString().padLeft(2, '0')}:${notif.time.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        // Gunakan border seragam agar borderRadius tidak error
        border: Border.all(color: colors.borderPrimary),
      ),
      // ClipRRect memastikan pita merah tidak keluar dari sudut yang melengkung
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: Stack(
          children: [
            // --- PITA MERAH (Hanya untuk notifikasi penting) ---
            if (notif.isUrgent)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: Colors.red),
              ),

            // --- KONTEN UTAMA ---
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notif.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notif.icon, color: notif.iconColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notif.title,
                                style: AppTypography.textMSemibold,
                              ),
                            ),
                            Text(
                              timeStr,
                              style: AppTypography.textXSRegular.copyWith(
                                color: colors.contentSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          notif.message,
                          style: AppTypography.textSRegular.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),

                        // Jika ada ekstra info (SKU / Sisa Kg)
                        if (notif.sku != null || notif.extraText != null) ...[
                          const SizedBox(height: AppSpacing.m),
                          Row(
                            children: [
                              if (notif.sku != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.backgroundDisabled,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    notif.sku!,
                                    style: AppTypography.textXSSemibold,
                                  ),
                                ),
                              const SizedBox(width: AppSpacing.s),
                              if (notif.extraText != null)
                                Text(
                                  notif.extraText!,
                                  style: AppTypography.textXSSemibold.copyWith(
                                    color: notif.isUrgent
                                        ? Colors.red
                                        : colors.contentSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
