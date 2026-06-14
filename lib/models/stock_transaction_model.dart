import 'package:uuid/uuid.dart';

enum TransactionType { inStock, outStock }

class StockTransactionModel {
  final String id;
  final String productId;
  final TransactionType type;
  final double quantity;
  final double remainingQuantity;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;

  StockTransactionModel({
    String? id,
    required this.productId,
    required this.type,
    required this.quantity,
    double? remainingQuantity,
    this.expiryDate,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       remainingQuantity =
           remainingQuantity ??
           (type == TransactionType.inStock ? quantity : 0),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type.name,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockTransactionModel.fromMap(Map<String, dynamic> map) {
    return StockTransactionModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      quantity: (map['quantity'] as num).toDouble(),
      remainingQuantity: (map['remaining_quantity'] as num).toDouble(),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'])
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
