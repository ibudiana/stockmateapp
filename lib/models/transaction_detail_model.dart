import 'package:stockmateapp/models/stock_transaction_model.dart';

class TransactionDetailModel {
  final StockTransactionModel transaction;
  final String productName;
  final String productSku;

  TransactionDetailModel({
    required this.transaction,
    required this.productName,
    required this.productSku,
  });

  factory TransactionDetailModel.fromMap(Map<String, dynamic> map) {
    return TransactionDetailModel(
      // Parsing data transaksi
      transaction: StockTransactionModel.fromMap(map),
      // Parsing ekstra data dari tabel products (hasil JOIN)
      productName: map['product_name'] as String,
      productSku: map['product_sku'] as String,
    );
  }
}