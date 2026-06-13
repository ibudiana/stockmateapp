part of 'widgets.dart';

enum AppSnackbarType { success, error, notice, info }

class AppSnackbar {
  /// Base method untuk menampilkan Snackbar
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    Color backgroundColor;
    Color textColor = colors.contentPrimaryInverse;
    IconData icon;

    switch (type) {
      case AppSnackbarType.success:
        backgroundColor = colors.backgroundPositive;
        icon = Icons.check_circle_outline;
        break;
      case AppSnackbarType.error:
        backgroundColor = colors.backgroundNegative;
        icon = Icons.error_outline;
        break;
      case AppSnackbarType.notice:
        backgroundColor = colors.backgroundNotice;
        icon = Icons.warning_amber_outlined;
        break;
      case AppSnackbarType.info:
        backgroundColor = colors.backgroundBrand; // atau backgroundInfo
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      // Transparan karena kita akan menggunakan Container di dalamnya untuk kontrol border & radius
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(AppSpacing.l),
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.s),
          boxShadow: [
            BoxShadow(
              color: colors.backgroundInverse.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: AppTypography.textMSemibold.copyWith(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                  ],
                  Text(
                    message,
                    style: AppTypography.textSRegular.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            // Tombol Tutup (Close Button)
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s),
                child: Icon(
                  Icons.close,
                  color: textColor.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Menyembunyikan snackbar yang sedang aktif (jika ada) sebelum memunculkan yang baru
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // --- Shadcn-like Helper Methods ---

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppSnackbarType.success,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppSnackbarType.error);
  }

  static void showNotice(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppSnackbarType.notice);
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    show(context, message: message, title: title, type: AppSnackbarType.info);
  }
}
