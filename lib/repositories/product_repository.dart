import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/services/local/dao/product_dao.dart';

class ProductRepository {
  final ProductDao productDao;

  ProductRepository({required this.productDao});

  Future<List<ProductModel>> getProducts() async {
    return await productDao.getAllProducts();
  }

  Future<List<StockTransactionModel>> getActiveBatches(String productId) async {
    return await productDao.getActiveBatches(productId);
  }

  Future<void> saveProduct(
    ProductModel product, {
    bool isUpdate = false,
  }) async {
    if (isUpdate) {
      await productDao.updateProduct(product);
    } else {
      await productDao.insertProduct(product);
    }
  }

  Future<void> deleteProduct(String id) async {
    await productDao.deleteProduct(id);
  }

  Future<void> adjustStock({
    required String productId,
    required TransactionType type,
    required double quantity,
    DateTime? expiryDate,
    String? notes,
  }) async {
    final transaction = StockTransactionModel(
      productId: productId,
      type: type,
      quantity: quantity,
      expiryDate: expiryDate,
      notes: notes,
    );
    await productDao.addStockTransaction(transaction);
  }
}
