part of 'package:stockmateapp/views/screens/screens.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
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
          'Pilih Bahasa',
          style: AppTypography.headingM.copyWith(color: colors.contentBrand),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.contentPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceL0,
            borderRadius: BorderRadius.circular(AppRadius.m),
            border: Border.all(color: colors.borderPrimary),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageItem(
                title: 'Indonesia',
                flag: '🇮🇩',
                code: 'id',
                viewModel: viewModel,
                colors: colors,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Divider(height: 1, color: colors.borderPrimary),
              ),
              _buildLanguageItem(
                title: 'English (US)',
                flag: '🇺🇸',
                code: 'en',
                viewModel: viewModel,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required String title,
    required String flag,
    required String code,
    required SettingsViewModel viewModel,
    required AppColors colors,
  }) {
    final isSelected = viewModel.language == code;

    return InkWell(
      onTap: () => viewModel.updateSetting('language', code as bool),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            // Bisa pakai icon bendera atau text emoji
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                title,
                style: isSelected
                    ? AppTypography.textMSemibold
                    : AppTypography.textMRegular.copyWith(
                        color: colors.contentSecondary,
                      ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.contentBrand),
          ],
        ),
      ),
    );
  }
}
