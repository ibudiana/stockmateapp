import 'package:uuid/uuid.dart';

class ProductModel {
  final String id;
  final String sku;
  final String name;
  final String unit;
  final double minStock;
  final double currentStock; // Agregasi total stok saat ini
  final String? notes;
  final String? imagePath; // Path lokal di memori HP
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    String? id,
    required this.sku,
    required this.name,
    required this.unit,
    required this.minStock,
    this.currentStock = 0.0,
    this.notes,
    this.imagePath,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? unit,
    double? minStock,
    double? currentStock,
    String? notes,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      currentStock: currentStock ?? this.currentStock,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'unit': unit,
      'min_stock': minStock,
      'current_stock': currentStock,
      'notes': notes,
      'image_path': imagePath,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      minStock: (map['min_stock'] as num).toDouble(),
      currentStock: (map['current_stock'] as num).toDouble(),
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
