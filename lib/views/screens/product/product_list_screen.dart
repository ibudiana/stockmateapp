part of 'package:stockmateapp/views/screens/screens.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Ambil data saat layar pertama kali dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
    });

    // Listener ini akan mengupdate _searchQuery setiap kali user mengetik
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _showStockDialog(ProductModel product, TransactionType type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          StockAdjustmentDialog(product: product, initialType: type),
    );
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // Jangan lupa dispose untuk mencegah memory leak
    super.dispose();
  }

  // Fungsi untuk menentukan warna berdasarkan sisa hari kedaluwarsa
  Color _getExpiryColor(DateTime? expiryDate) {
    if (expiryDate == null)
      return Colors.green; // Jika tidak ada expired, aman (hijau)

    final now = DateTime.now();
    // Normalisasi waktu ke tengah malam agar perhitungan hari akurat
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

    final difference = exp.difference(today).inDays;

    if (difference < 7) {
      return Colors.red;
    } else if (difference < 14) {
      return Colors.orange;
    } else if (difference < 30) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // --- LOGIKA FILTER PENCARIAN ---
    final filteredProducts = viewModel.state.products.where((product) {
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final nameMatch = product.name.toLowerCase().contains(query);
      final skuMatch = product.sku.toLowerCase().contains(query);

      return nameMatch || skuMatch;
    }).toList();

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      // --- APPBAR DINAMIS ---
      appBar: AppBar(
        backgroundColor: colors.surfaceL0,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau SKU...',
                  border: InputBorder.none,
                  hintStyle: AppTypography.textMRegular.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
                style: AppTypography.textMRegular.copyWith(
                  color: colors.contentPrimary,
                ),
              )
            : Text(
                'Daftar Stok',
                style: AppTypography.headingL.copyWith(
                  color: colors.contentPrimary,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: colors.contentPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  // Jika sedang mencari lalu di-close, bersihkan teksnya
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  // Aktifkan mode pencarian
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.filter_list, color: colors.contentPrimary),
              onPressed: () {},
            ),
        ],
      ),

      body:
          viewModel.state.status == ProductStatus.loading &&
              viewModel.state.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // INFO GUDANG & LEGENDA
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- GUNAKAN filteredProducts.length ---
                      Text(
                        'Gudang Utama - ${filteredProducts.length} Barang',
                        style: AppTypography.textMRegular.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Row(
                        children: [
                          _buildLegendItem(Colors.red, '< 7 Hari'),
                          _buildLegendItem(Colors.orange, '< 14 Hari'),
                          _buildLegendItem(Colors.green, '> 30 Hari'),
                        ],
                      ),
                    ],
                  ),
                ),

                // LIST PRODUK
                Expanded(
                  // Jika hasil pencarian kosong, tampilkan pesan
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Produk tidak ditemukan',
                            style: AppTypography.textMRegular.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l,
                            vertical: AppSpacing.s,
                          ),
                          itemCount: filteredProducts
                              .length, // --- GUNAKAN filteredProducts ---
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.l),
                          itemBuilder: (context, index) {
                            final product =
                                filteredProducts[index]; // --- GUNAKAN filteredProducts ---
                            return _buildProductCard(context, product, colors);
                          },
                        ),
                ),
              ],
            ),

      // TOMBOL TAMBAH PRODUK (Sticky Bottom)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.contentBrand,
        onPressed: () {
          context.push('/products/form');
        },
        icon: Icon(Icons.add, color: colors.contentPrimaryInverse),
        label: Text(
          'Tambah Produk',
          style: AppTypography.textMSemibold.copyWith(
            color: colors.contentPrimaryInverse,
          ),
        ),
      ),

      // --- 2. GUNAKAN WIDGET NAV BAR GLOBAL ---
      // currentIndex: 1 karena ini adalah tab "Item"
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.textXSRegular),
        ],
      ),
    );
  }

  // CARD PRODUK INDIVIDUAL
  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    AppColors colors,
  ) {
    return InkWell(
      onTap: () => _showProductDetailsModal(product, colors),
      borderRadius: BorderRadius.circular(AppRadius.m),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceL0,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: colors.borderPrimary),
        ),
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar Thumbnail
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors.backgroundDisabled,
                borderRadius: BorderRadius.circular(AppRadius.s),
                image: product.imagePath != null
                    ? DecorationImage(
                        image: FileImage(File(product.imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imagePath != null
                  ? const SizedBox.shrink()
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: AppSpacing.m),

            // Info Dasar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTypography.headingM),
                  const SizedBox(height: 2),
                  Text(
                    product.sku,
                    style: AppTypography.textSRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Total Stok & Indikator Klik
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.currentStock.toStringAsFixed(0)} ${product.unit}',
                  style: AppTypography.headingM.copyWith(
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Detail',
                      style: AppTypography.textXSSemibold.copyWith(
                        color: colors.contentBrand,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colors.contentBrand,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MODAL DETAIL PRODUK (MUNCUL SAAT CARD DIKLIK)
  void _showProductDetailsModal(ProductModel product, AppColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal bisa menyesuaikan isi konten
      backgroundColor:
          Colors.transparent, // Transparan agar ujungnya bisa melengkung
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            color: colors.surfaceL0,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.l),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan konten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- GARIS HANDLE MODAL ---
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.borderPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // --- HEADER: NAMA & TOMBOL EDIT ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTypography.headingL),
                          Text(
                            'SKU: ${product.sku}',
                            style: AppTypography.textMRegular.copyWith(
                              color: colors.contentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colors.contentBrand,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Tutup modal dulu
                        context.push(
                          '/products/form',
                          extra: product,
                        ); // Lalu navigasi ke edit
                      },
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl2),

                // --- DAFTAR BATCH (FutureBuilder yang dipindah ke sini) ---
                Text(
                  'RINCIAN STOK AKTIF',
                  style: AppTypography.textXSSemibold.copyWith(
                    color: colors.contentSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                FutureBuilder<List<StockTransactionModel>>(
                  future: context
                      .read<ProductViewModel>()
                      .repository
                      .getActiveBatches(product.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.m,
                        ),
                        child: Text(
                          'Belum ada riwayat stok masuk atau stok telah habis.',
                          style: AppTypography.textSRegular.copyWith(
                            color: colors.contentSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: snapshot.data!.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final batch = entry.value;
                        final expString = batch.expiryDate != null
                            ? "${batch.expiryDate!.day}/${batch.expiryDate!.month}/${batch.expiryDate!.year}"
                            : "Tanpa batas";

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.s),
                          padding: const EdgeInsets.all(AppSpacing.m),
                          decoration: BoxDecoration(
                            color: colors.backgroundPrimary,
                            borderRadius: BorderRadius.circular(AppRadius.s),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: _getExpiryColor(
                                      batch.expiryDate,
                                    ), // Gunakan warna dinamis
                                  ),
                                  const SizedBox(width: AppSpacing.s),
                                  Text(
                                    'Batch $index: Sisa ${batch.remainingQuantity.toInt()}',
                                    style: AppTypography.textMSemibold,
                                  ),
                                ],
                              ),
                              Text(
                                'Exp: $expString',
                                style: AppTypography.textSRegular.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // --- TOMBOL AKSI IN/OUT ---
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        text: 'Stock Keluar',
                        icon: Icons.remove_circle_outline,
                        onPressed: () {
                          Navigator.pop(context); // Tutup modal dulu
                          _showStockDialog(product, TransactionType.outStock);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: AppButton.primary(
                        text: 'Stock Masuk',
                        icon: Icons.add_circle_outline,
                        onPressed: () {
                          Navigator.pop(context); // Tutup modal dulu
                          _showStockDialog(product, TransactionType.inStock);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
