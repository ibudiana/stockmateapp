import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/repositories/product_repository.dart';
import 'package:stockmateapp/services/local/dao/product_dao.dart';

// Membuat Mock (Tiruan) untuk DAO
class MockProductDao extends Mock implements ProductDao {}

// Setup Fake untuk tipe data kustom jika mocktail membutuhkannya sebagai argumen
class FakeProductModel extends Fake implements ProductModel {}

class FakeStockTransactionModel extends Fake implements StockTransactionModel {}

void main() {
  late ProductRepository repository;
  late MockProductDao mockDao;

  setUpAll(() {
    registerFallbackValue(FakeProductModel());
    registerFallbackValue(FakeStockTransactionModel());
  });

  setUp(() {
    mockDao = MockProductDao();
    repository = ProductRepository(productDao: mockDao);
  });

  group('ProductRepository Tests', () {
    final dummyProduct = ProductModel(
      id: 'prod-1',
      sku: 'SKU-001',
      name: 'Beras',
      unit: 'kg',
      minStock: 10,
    );

    test('getProducts harus memanggil getAllProducts dari DAO', () async {
      // Arrange
      when(
        () => mockDao.getAllProducts(),
      ).thenAnswer((_) async => [dummyProduct]);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result.length, 1);
      expect(result.first.name, 'Beras');
      verify(() => mockDao.getAllProducts()).called(1);
    });

    test(
      'saveProduct harus memanggil insertProduct jika isUpdate false',
      () async {
        // Arrange
        when(() => mockDao.insertProduct(any())).thenAnswer((_) async => {});

        // Act
        await repository.saveProduct(dummyProduct, isUpdate: false);

        // Assert
        verify(() => mockDao.insertProduct(dummyProduct)).called(1);
        verifyNever(
          () => mockDao.updateProduct(any()),
        ); // Pastikan update tidak dipanggil
      },
    );

    test(
      'saveProduct harus memanggil updateProduct jika isUpdate true',
      () async {
        // Arrange
        when(() => mockDao.updateProduct(any())).thenAnswer((_) async => {});

        // Act
        await repository.saveProduct(dummyProduct, isUpdate: true);

        // Assert
        verify(() => mockDao.updateProduct(dummyProduct)).called(1);
        verifyNever(
          () => mockDao.insertProduct(any()),
        ); // Pastikan insert tidak dipanggil
      },
    );

    test(
      'adjustStock harus membuat StockTransactionModel dan memanggil addStockTransaction',
      () async {
        // Arrange
        when(
          () => mockDao.addStockTransaction(any()),
        ).thenAnswer((_) async => {});

        // Act
        await repository.adjustStock(
          productId: 'prod-1',
          type: TransactionType.inStock,
          quantity: 50,
        );

        // Assert
        // Verifikasi bahwa addStockTransaction dipanggil dengan objek yang memiliki data yang sesuai
        verify(
          () => mockDao.addStockTransaction(
            any(
              that: isA<StockTransactionModel>()
                  .having((t) => t.productId, 'productId', 'prod-1')
                  .having((t) => t.type, 'type', TransactionType.inStock)
                  .having((t) => t.quantity, 'quantity', 50.0),
            ),
          ),
        ).called(1);
      },
    );

    test('getActiveBatches harus memanggil fungsi DAO yang sesuai', () async {
      // Arrange
      final dummyBatch = StockTransactionModel(
        productId: 'prod-1',
        type: TransactionType.inStock,
        quantity: 20,
        remainingQuantity: 20,
      );
      when(
        () => mockDao.getActiveBatches('prod-1'),
      ).thenAnswer((_) async => [dummyBatch]);

      // Act
      final result = await repository.getActiveBatches('prod-1');

      // Assert
      expect(result.length, 1);
      expect(result.first.remainingQuantity, 20.0);
      verify(() => mockDao.getActiveBatches('prod-1')).called(1);
    });
  });
}
