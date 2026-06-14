part of 'package:stockmateapp/views/screens/screens.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final ProductModel product;
  final TransactionType initialType;

  const StockAdjustmentDialog({
    super.key,
    required this.product,
    required this.initialType,
  });

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    // Bersihkan form saat dialog pertama kali dibuka
    context.read<ProductViewModel>().stockForm.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && mounted) {
      // Format sederhana, sesuaikan dengan package intl jika ada (misal: DateFormat('MM/dd/yyyy').format(picked))
      context.read<ProductViewModel>().stockForm.expiryDateController.text =
          picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      backgroundColor: colors.surfaceL0,
      insetPadding: const EdgeInsets.all(AppSpacing.l),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER PRODUK ---
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.backgroundDisabled,
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      image: widget.product.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(widget.product.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: AppTypography.headingM,
                        ),
                        Text(
                          'SKU: ${widget.product.sku}',
                          style: AppTypography.textXSRegular,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                          child: Text(
                            'Stok saat ini: ${widget.product.currentStock} ${widget.product.unit}',
                            style: AppTypography.textXSSemibold.copyWith(
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl2),

              // --- FORM INPUT ---
              AppTextInput.text(
                label: 'JUMLAH STOCK',
                hint: '0',
                controller: viewModel.stockForm.quantityController,
                keyboardType: TextInputType.number,
                suffixText: widget.product.unit,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.m),

              // Tanggal kedaluwarsa hanya relevan jika barang masuk (opsional jika barang keluar)
              if (_selectedType == TransactionType.inStock) ...[
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: AppTextInput.text(
                      label: 'WAKTU KADALUARSA',
                      hint: 'Pilih tanggal',
                      controller: viewModel.stockForm.expiryDateController,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: colors.contentSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              AppTextInput.text(
                label: 'CATATAN (OPSIONAL)',
                hint: 'Contoh: Restock bulanan...',
                controller: viewModel.stockForm.notesController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- TYPE SELECTOR (MASUK / KELUAR) ---
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      title: 'STOCK MASUK',
                      icon: Icons.add_circle_outline,
                      isSelected: _selectedType == TransactionType.inStock,
                      activeColor: Colors.teal,
                      onTap: () => setState(
                        () => _selectedType = TransactionType.inStock,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      title: 'STOCK KELUAR',
                      icon: Icons.remove_circle_outline,
                      isSelected: _selectedType == TransactionType.outStock,
                      activeColor: Colors.red,
                      onTap: () => setState(
                        () => _selectedType = TransactionType.outStock,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl2),

              // --- ACTION BUTTONS ---
              AppButton.secondary(
                text: 'Batal',
                isFullWidth: true,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton.primary(
                text: 'Simpan Penyesuaian',
                isFullWidth: true,
                isLoading: viewModel.state.status == ProductStatus.loading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await viewModel.adjustStock(
                      widget.product.id,
                      _selectedType,
                    );
                    if (viewModel.state.status == ProductStatus.success &&
                        context.mounted) {
                      AppSnackbar.showSuccess(
                        context,
                        message: viewModel.state.message!,
                      );
                      Navigator.pop(context); // Tutup dialog jika sukses
                    } else if (viewModel.state.status == ProductStatus.error &&
                        context.mounted) {
                      AppSnackbar.showError(
                        context,
                        message: viewModel.state.message!,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : colors.surfaceL0,
          border: Border.all(
            color: isSelected ? activeColor : colors.borderPrimary,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : colors.contentSecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.textXSSemibold.copyWith(
                color: isSelected ? activeColor : colors.contentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
