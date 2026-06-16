part of 'widgets.dart';

enum TextInputVariant { text, email, password }

class AppTextInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputVariant variant;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  // --- TAMBAHAN PROPERTI BARU ---
  final TextInputType? keyboardType;
  final String? suffixText;
  final Widget? suffixIcon;
  final int maxLines;

  const AppTextInput._({
    required this.label,
    required this.hint,
    required this.controller,
    required this.variant,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.suffixText,
    this.suffixIcon,
    this.maxLines = 1, // Default 1 baris
  });

  factory AppTextInput.text({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? prefixIcon,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    String? suffixText,
    Widget? suffixIcon,
    int maxLines = 1,
    bool obscureText =
        false, // Tambahan untuk opsi teks biasa yang bisa di-obscure
  }) {
    return AppTextInput._(
      label: label,
      hint: hint,
      controller: controller,
      variant: TextInputVariant.text,
      prefixIcon: prefixIcon,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      maxLines: maxLines,
    );
  }

  factory AppTextInput.email({
    required String label,
    required String hint,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return AppTextInput._(
      label: label,
      hint: hint,
      controller: controller,
      variant: TextInputVariant.email,
      prefixIcon: Icons.email_outlined,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
    );
  }

  factory AppTextInput.password({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? prefixIcon = Icons.lock_outline,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return AppTextInput._(
      label: label,
      hint: hint,
      controller: controller,
      variant: TextInputVariant.password,
      prefixIcon: prefixIcon,
      validator: validator,
      onChanged: onChanged,
    );
  }

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.variant == TextInputVariant.password;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: AppTypography.textXSSemibold.copyWith(
            color: colors.contentPrimary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          // Gunakan custom keyboardType jika ada, jika tidak fallback ke variant
          keyboardType:
              widget.keyboardType ??
              (widget.variant == TextInputVariant.email
                  ? TextInputType.emailAddress
                  : TextInputType.text),

          // Terapkan maxLines (password harus selalu 1 baris)
          maxLines: widget.variant == TextInputVariant.password
              ? 1
              : widget.maxLines,

          style: AppTypography.textMRegular.copyWith(
            color: colors.contentPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.textMRegular.copyWith(
              color: colors.contentSecondary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: colors.contentPrimary.withOpacity(0.6),
                    size: 22,
                  )
                : null,

            // Menangani Suffix Icon (Visibility Toggle / Custom Icon)
            suffixIcon: widget.variant == TextInputVariant.password
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: colors.contentSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : widget.suffixIcon,

            // Menambahkan Suffix Text (misal: "kg")
            suffixText: widget.suffixText,
            suffixStyle: AppTypography.textMRegular.copyWith(
              color: colors.contentSecondary,
            ),

            filled: true,
            fillColor: colors.contentTertiary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
              borderSide: BorderSide(
                color: colors.borderPrimary,
                width: AppBorder.widthXs,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
              borderSide: BorderSide(
                color: colors.borderPrimary,
                width: AppBorder.widthXs,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
              borderSide: BorderSide(
                color: colors.borderBrand,
                width: AppBorder.widthS,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
              borderSide: BorderSide(
                color: colors.borderNegative,
                width: AppBorder.widthXs,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
              borderSide: BorderSide(
                color: colors.borderNegative,
                width: AppBorder.widthS,
              ),
            ),
            errorStyle: AppTypography.textSRegular.copyWith(
              color: colors.contentNegative,
            ),
          ),
        ),
      ],
    );
  }
}
