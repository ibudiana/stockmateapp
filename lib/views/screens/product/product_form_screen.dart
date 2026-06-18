part of 'package:stockmateapp/views/screens/screens.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product; // Jika null = Tambah Baru, Jika ada = Edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, muat data produk ke dalam controller form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProductViewModel>();
      if (_isEdit) {
        viewModel.productForm.loadData(widget.product!);
      } else {
        viewModel.productForm.clear(); // Pastikan form kosong untuk data baru
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: AppTypography.headingM,
        ),
        backgroundColor: colors.surfaceL0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.contentPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              icon: Icon(Icons.more_vert, color: colors.contentPrimary),
              onPressed: () {}, // Opsi tambahan
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION 1: FOTO PRODUK ---
                    _buildSectionContainer(
                      context,
                      title: 'FOTO PRODUK',
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: colors.backgroundDisabled,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.m,
                                ),
                                // Tampilkan gambar dari memori lokal HP
                                image: viewModel.productForm.imagePath != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(
                                            viewModel.productForm.imagePath!,
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              // Jika kosong, tampilkan icon
                              child: viewModel.productForm.imagePath != null
                                  ? const SizedBox.shrink()
                                  : const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              'Ubah foto produk Anda untuk identifikasi\nyang lebih mudah di gudang.',
                              textAlign: TextAlign.center,
                              style: AppTypography.textMRegular.copyWith(
                                color: colors.contentPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Maksimal 5MB. Format JPG, PNG.',
                              style: AppTypography.textSRegular.copyWith(
                                color: colors.contentSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            AppButton.link(
                              // Teks berubah otomatis jika gambar sudah ada
                              text: viewModel.productForm.imagePath != null
                                  ? 'Ganti Foto'
                                  : 'Unggah Foto',
                              onPressed: () async {
                                // Panggil fungsi pickImage dari ViewModel
                                await viewModel.pickImage();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- SECTION 2: INFORMASI DASAR ---
                    _buildSectionContainer(
                      context,
                      title: 'INFORMASI DASAR',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextInput.text(
                            label: 'SKU (Stock Keeping Unit)',
                            hint: 'CTH: BRS-001',
                            controller: viewModel.productForm.skuController,
                            // Jika edit = Gembok. Jika tambah baru = Tombol Scan Barcode
                            suffixIcon: _isEdit
                                ? const Icon(Icons.lock_outline, size: 20)
                                : IconButton(
                                    icon: Icon(
                                      Icons.qr_code_scanner,
                                      color: colors
                                          .contentBrand, // Warna biru/utama
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      // Buka layar kamera bawaan package
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              // ignore: deprecated_member_use
                                              const SimpleBarcodeScannerPage(),
                                        ),
                                      );

                                      // Jika user berhasil memindai barcode (tidak menekan tombol cancel/-1)
                                      if (res is String && res != '-1') {
                                        // Otomatis isi teks SKU dengan hasil scan
                                        viewModel
                                                .productForm
                                                .skuController
                                                .text =
                                            res;

                                        // Jika ada validasi/rebuild yang diperlukan
                                        setState(() {});
                                      }
                                    },
                                  ),
                            validator: (v) =>
                                v!.isEmpty ? 'SKU wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.m),

                          AppTextInput.text(
                            label: 'Nama Produk',
                            hint: 'Contoh: Beras Pandan Wangi',
                            controller: viewModel.productForm.nameController,
                            validator: (v) =>
                                v!.isEmpty ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.m),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Satuan',
                                style: AppTypography.textSRegular.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              DropdownButtonFormField<String>(
                                value: () {
                                  final currentText = viewModel
                                      .productForm
                                      .unitController
                                      .text
                                      .trim();
                                  if (currentText.isEmpty) return null;

                                  final availableUnits = [
                                    'Kg',
                                    'Pcs',
                                    'Liter',
                                    'Kotak',
                                    'Bks',
                                    'Lusin',
                                    'Gram',
                                  ];

                                  // Cari satuan yang cocok mengabaikan huruf besar/kecil
                                  for (var unit in availableUnits) {
                                    if (unit.toLowerCase() ==
                                        currentText.toLowerCase()) {
                                      return unit; // Kembalikan nilai yang ada di daftar
                                    }
                                  }

                                  // Jika sama sekali tidak ada di daftar, kita tetap masukkan ke UI
                                  // agar tidak crash, tapi berikan peringatan untuk diedit
                                  return null;
                                }(),
                                decoration: InputDecoration(
                                  hintText: 'Pilih Satuan',
                                  hintStyle: AppTypography.textMRegular
                                      .copyWith(color: colors.contentSecondary),
                                  filled: true,
                                  fillColor: colors.backgroundDisabled,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.m,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: colors.contentPrimary,
                                ),
                                // Pastikan items di sini SAMA PERSIS dengan availableUnits di atas
                                items:
                                    [
                                          'Kg',
                                          'Pcs',
                                          'Liter',
                                          'Kotak',
                                          'Bks',
                                          'Lusin',
                                          'Gram',
                                        ]
                                        .map(
                                          (unit) => DropdownMenuItem(
                                            value: unit,
                                            child: Text(
                                              unit,
                                              style: AppTypography.textMRegular,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    viewModel.productForm.unitController.text =
                                        val;
                                  }
                                },
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Satuan wajib diisi'
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.m),

                          AppTextInput.text(
                            label: 'Ambang Stok Minimum',
                            hint: '50',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            controller:
                                viewModel.productForm.minStockController,
                            suffixText:
                                'KG', // Opsional, bisa dibuat dinamis sesuai satuan
                            validator: (v) =>
                                v!.isEmpty ? 'Ambang stok wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: colors.contentSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Notifikasi akan muncul jika stok di bawah angka ini.',
                                style: AppTypography.textSRegular.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // --- SECTION 3: CATATAN TAMBAHAN ---
                    _buildSectionContainer(
                      context,
                      title: 'CATATAN TAMBAHAN',
                      child: AppTextInput.text(
                        label: '', // Label sudah ada di judul section
                        hint: 'Contoh: Penyimpanan harus di area kering...',
                        controller: viewModel.productForm.notesController,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM ACTION BAR ---
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: colors.surfaceL0,
                border: Border(top: BorderSide(color: colors.borderPrimary)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Footer (Hanya muncul saat edit)
                  if (_isEdit) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // Format tanggal sederhana
                          'Terakhir diubah: ${widget.product!.updatedAt.day}/${widget.product!.updatedAt.month}/${widget.product!.updatedAt.year}',
                          style: AppTypography.textSRegular.copyWith(
                            color: colors.contentSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: widget.product!.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              widget.product!.isActive ? 'AKTIF' : 'NON-AKTIF',
                              style: AppTypography.textXSSemibold.copyWith(
                                color: widget.product!.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      if (_isEdit) ...[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.backgroundNegative,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.l,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.m,
                                ),
                              ),
                            ),
                            onPressed: () => _confirmDelete(context, viewModel),
                            child: Text(
                              'Hapus',
                              style: AppTypography.textMSemibold.copyWith(
                                color: colors.contentPrimaryInverse,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                      ],
                      Expanded(
                        flex: 1,
                        child: AppButton.secondary(
                          text: 'Batal',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        flex: _isEdit ? 1 : 2,
                        child: AppButton.primary(
                          text: 'Simpan',
                          icon: Icons.save,
                          isLoading:
                              viewModel.state.status == ProductStatus.loading,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await viewModel.saveProduct(
                                existingProduct: widget.product,
                              );

                              if (viewModel.state.status ==
                                      ProductStatus.success &&
                                  context.mounted) {
                                AppSnackbar.showSuccess(
                                  context,
                                  message: viewModel.state.message!,
                                );
                                Navigator.pop(context); // Kembali ke list
                              } else if (viewModel.state.status ==
                                      ProductStatus.error &&
                                  context.mounted) {
                                AppSnackbar.showError(
                                  context,
                                  message: viewModel.state.message!,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membungkus section dengan border putih sesuai desain
  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textXSSemibold.copyWith(
              color: colors.contentSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          child,
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductViewModel viewModel) {
    // Tampilkan dialog konfirmasi sebelum menghapus
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text(
          'Apakah Anda yakin ingin menonaktifkan produk ini? Riwayat stok akan tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.deleteProduct(widget.product!.id);
              if (context.mounted) {
                AppSnackbar.showSuccess(
                  context,
                  message: 'Produk berhasil dihapus',
                );
                Navigator.pop(context); // Kembali ke halaman list
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
