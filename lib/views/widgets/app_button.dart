part of 'widgets.dart';

enum AppButtonVariant { primary, outline, link }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton._({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    required this.variant,
    this.icon,
    this.isFullWidth = false,
  });

  // --- Shadcn-like Named Constructors ---

  factory AppButton.primary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.primary,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.secondary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.outline,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.outline({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.outline,
      icon: icon,
      isFullWidth: isFullWidth,
    );
  }

  factory AppButton.link({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return AppButton._(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.link,
      icon: icon,
      isFullWidth: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: variant == AppButtonVariant.primary
                  ? colors.contentPrimaryInverse
                  : colors.contentBrand,
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(text),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.s),
                Icon(icon, size: 20),
              ],
            ],
          );

    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.backgroundBrand,
            // 1. Triknya di sini: Jika loading, gunakan warna brand namun sedikit transparan.
            // Jika disable biasa, baru gunakan warna backgroundDisabled bawaan.
            disabledBackgroundColor: isLoading
                ? colors.backgroundBrand.withValues(alpha: 0.7)
                : colors.backgroundDisabled,

            // 2. Pastikan warna konten (loading indicator) tetap putih saat disabled karena loading
            disabledForegroundColor: isLoading
                ? colors.contentPrimaryInverse
                : colors.contentDisabled,

            foregroundColor: colors.contentPrimaryInverse,
            textStyle: AppTypography.textLSemibold,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.m,
            ),
          ),
          child: buttonContent,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.contentBrand,
            side: BorderSide(
              color: colors.borderBrand,
              width: AppBorder.widthXs,
            ),
            textStyle: AppTypography.textLSemibold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.m,
            ),
          ),
          child: buttonContent,
        );
        break;
      case AppButtonVariant.link:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.contentBrand,
            textStyle: AppTypography.textMSemibold,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: buttonContent,
        );
        break;
    }

    if (isFullWidth && variant != AppButtonVariant.link) {
      return SizedBox(
        width: double.infinity,
        height: 52, // Tinggi standar button
        child: button,
      );
    }

    return button;
  }
}
