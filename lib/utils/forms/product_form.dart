import 'package:flutter/material.dart';
import 'package:stockmateapp/models/product_model.dart';

class ProductForm {
  final skuController = TextEditingController();
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final minStockController = TextEditingController();
  final notesController = TextEditingController();

  String? imagePath;

  bool validate(Function(String) onError) {
    if (skuController.text.trim().isEmpty) {
      onError("SKU tidak boleh kosong.");
      return false;
    }
    if (nameController.text.trim().isEmpty) {
      onError("Nama Produk tidak boleh kosong.");
      return false;
    }
    if (minStockController.text.trim().isEmpty ||
        double.tryParse(minStockController.text.trim()) == null) {
      onError("Ambang batas stok minimum harus berupa angka yang valid.");
      return false;
    }
    return true;
  }

  void loadData(ProductModel product) {
    skuController.text = product.sku;
    nameController.text = product.name;
    unitController.text = product.unit;
    minStockController.text = product.minStock.toString();
    notesController.text = product.notes ?? '';
    imagePath = product.imagePath;
  }

  void clear() {
    skuController.clear();
    nameController.clear();
    unitController.text = 'kg'; // Default value
    minStockController.clear();
    notesController.clear();
    imagePath = null;
  }

  void dispose() {
    skuController.dispose();
    nameController.dispose();
    unitController.dispose();
    minStockController.dispose();
    notesController.dispose();
  }
}

class StockAdjustmentForm {
  final quantityController = TextEditingController();
  final expiryDateController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? get expiryDate {
    if (expiryDateController.text.isEmpty) return null;
    try {
      // Asumsi format di UI YYYY-MM-DD
      return DateTime.parse(expiryDateController.text);
    } catch (e) {
      return null;
    }
  }

  bool validate(Function(String) onError) {
    if (quantityController.text.trim().isEmpty ||
        double.tryParse(quantityController.text.trim()) == null) {
      onError("Jumlah stok harus berupa angka yang valid.");
      return false;
    }
    final qty = double.parse(quantityController.text.trim());
    if (qty <= 0) {
      onError("Jumlah stok harus lebih dari 0.");
      return false;
    }
    return true;
  }

  void clear() {
    quantityController.clear();
    expiryDateController.clear();
    notesController.clear();
  }

  void dispose() {
    quantityController.dispose();
    expiryDateController.dispose();
    notesController.dispose();
  }
}
