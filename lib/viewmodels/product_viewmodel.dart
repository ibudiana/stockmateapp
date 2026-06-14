import 'package:flutter/material.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/repositories/product_repository.dart';
import 'package:stockmateapp/utils/forms/product_form.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ProductStatus { idle, loading, success, error }

class ProductState {
  final ProductStatus status;
  final String? message;
  final List<ProductModel> products;
  final List<StockTransactionModel> activeBatches;

  const ProductState({
    this.status = ProductStatus.idle,
    this.message,
    this.products = const [],
    this.activeBatches = const [],
  });

  ProductState copyWith({
    ProductStatus? status,
    String? message,
    List<ProductModel>? products,
    List<StockTransactionModel>? activeBatches,
  }) {
    return ProductState(
      status: status ?? this.status,
      message:
          message, // Membiarkan null jika tidak diisi agar error lama hilang
      products: products ?? this.products,
      activeBatches: activeBatches ?? this.activeBatches,
    );
  }
}

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  final productForm = ProductForm();
  final stockForm = StockAdjustmentForm();

  ProductState _state = const ProductState();
  ProductState get state => _state;

  ProductViewModel({required this.repository}) {
    productForm.unitController.text =
        'kg'; // Default unit saat pertama kali diinisialisasi
  }

  void _setState(ProductState newState) {
    _state = newState;
    notifyListeners();
  }

  void _showError(String message) {
    _setState(_state.copyWith(status: ProductStatus.error, message: message));
  }

  // --- MENGAMBIL DATA ---
  Future<void> fetchProducts() async {
    _setState(_state.copyWith(status: ProductStatus.loading));
    try {
      final products = await repository.getProducts();
      _setState(
        _state.copyWith(status: ProductStatus.success, products: products),
      );
    } catch (e) {
      _showError("Gagal memuat produk: $e");
    }
  }

  Future<void> fetchActiveBatches(String productId) async {
    _setState(_state.copyWith(status: ProductStatus.loading));
    try {
      final batches = await repository.getActiveBatches(productId);
      _setState(
        _state.copyWith(status: ProductStatus.success, activeBatches: batches),
      );
    } catch (e) {
      _showError("Gagal memuat rincian stok: $e");
    }
  }

  // --- CRUD PRODUK ---
  Future<void> saveProduct({ProductModel? existingProduct}) async {
    if (!productForm.validate(_showError)) return;

    _setState(_state.copyWith(status: ProductStatus.loading));

    try {
      final isUpdate = existingProduct != null;

      final product = ProductModel(
        id: isUpdate ? existingProduct.id : null,
        imagePath: productForm.imagePath,
        sku: productForm.skuController.text.trim(),
        name: productForm.nameController.text.trim(),
        unit: productForm.unitController.text.trim(),
        minStock: double.parse(productForm.minStockController.text.trim()),
        notes: productForm.notesController.text.trim(),
        currentStock: isUpdate ? existingProduct.currentStock : 0.0,
        createdAt: isUpdate ? existingProduct.createdAt : null,
      );

      await repository.saveProduct(product, isUpdate: isUpdate);
      productForm.clear();

      // 1. Refresh list DULU
      await fetchProducts();

      // 2. BARU set status success dan pesannya (agar tidak tertimpa null)
      _setState(
        _state.copyWith(
          status: ProductStatus.success,
          message: isUpdate ? "Produk diperbarui" : "Produk ditambahkan",
        ),
      );
    } catch (e) {
      _showError("Gagal menyimpan produk: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    _setState(_state.copyWith(status: ProductStatus.loading));
    try {
      await repository.deleteProduct(id);
      _setState(
        _state.copyWith(
          status: ProductStatus.success,
          message: "Produk dihapus",
        ),
      );
      await fetchProducts();
    } catch (e) {
      _showError("Gagal menghapus produk: $e");
    }
  }

  // --- FITUR UNGGAH FOTO ---
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      // 1. Buka galeri pengguna
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompresi kualitas menjadi 80% agar database ringan
        maxWidth: 800, // Batasi resolusi maksimal
      );

      if (image != null) {
        // 2. Dapatkan folder dokumen aplikasi yang aman (tidak terhapus saat clear cache)
        final directory = await getApplicationDocumentsDirectory();

        // 3. Buat nama file baru yang unik
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final savedImagePath = '${directory.path}/$fileName';

        // 4. Salin gambar dari cache galeri ke folder aplikasi kita
        await File(image.path).copy(savedImagePath);

        // 5. Simpan path-nya ke dalam form
        productForm.imagePath = savedImagePath;

        // Trigger update UI agar gambar langsung muncul
        _setState(_state.copyWith());
      }
    } catch (e) {
      _showError("Gagal memuat gambar: $e");
    }
  }

  // --- PENYESUAIAN STOK (IN / OUT) ---
  Future<void> adjustStock(String productId, TransactionType type) async {
    if (!stockForm.validate(_showError)) return;

    _setState(_state.copyWith(status: ProductStatus.loading));

    try {
      final quantity = double.parse(stockForm.quantityController.text.trim());

      await repository.adjustStock(
        productId: productId,
        type: type,
        quantity: quantity,
        expiryDate: stockForm.expiryDate,
        notes: stockForm.notesController.text.trim(),
      );

      stockForm.clear();

      // 1. Refresh list master dan rincian batch DULU
      await fetchProducts();
      await fetchActiveBatches(productId);

      // 2. BARU set status success dan pesannya
      _setState(
        _state.copyWith(
          status: ProductStatus.success,
          message: "Penyesuaian stok berhasil",
        ),
      );
    } catch (e) {
      final errMsg = e.toString().replaceAll("Exception: ", "");
      _showError(errMsg);
    }
  }

  void resetState() {
    _setState(_state.copyWith(status: ProductStatus.idle, message: null));
  }

  @override
  void dispose() {
    productForm.dispose();
    stockForm.dispose();
    super.dispose();
  }
}
