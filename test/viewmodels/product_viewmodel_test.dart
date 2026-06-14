import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/repositories/product_repository.dart';
import 'package:stockmateapp/viewmodels/product_viewmodel.dart';

// Mock Repository
class MockProductRepository extends Mock implements ProductRepository {}

class FakeProductModel extends Fake implements ProductModel {}

void main() {
  late ProductViewModel viewModel;
  late MockProductRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeProductModel());
    registerFallbackValue(TransactionType.inStock);
  });

  setUp(() {
    mockRepository = MockProductRepository();
    viewModel = ProductViewModel(repository: mockRepository);
  });

  group('ProductViewModel - Form Validations', () {
    test('saveProduct gagal jika nama kosong', () async {
      // Arrange
      viewModel.productForm.skuController.text = 'SKU-001';
      viewModel.productForm.nameController.text = ''; // Kosong
      viewModel.productForm.minStockController.text = '10';

      // Act
      await viewModel.saveProduct();

      // Assert
      expect(viewModel.state.status, ProductStatus.error);
      expect(
        viewModel.state.message,
        contains('Nama Produk tidak boleh kosong'),
      );
      verifyNever(() => mockRepository.saveProduct(any()));
    });

    test('adjustStock gagal jika quantity bukan angka', () async {
      // Arrange
      viewModel.stockForm.quantityController.text = 'abc';

      // Act
      await viewModel.adjustStock('prod-1', TransactionType.inStock);

      // Assert
      expect(viewModel.state.status, ProductStatus.error);
      expect(viewModel.state.message, contains('harus berupa angka'));
      verifyNever(
        () => mockRepository.adjustStock(
          productId: any(named: 'productId'),
          type: any(named: 'type'),
          quantity: any(named: 'quantity'),
        ),
      );
    });
  });

  group('ProductViewModel - Repository Interactions', () {
    final dummyProduct = ProductModel(
      id: 'prod-1',
      sku: 'SKU-001',
      name: 'Beras',
      unit: 'kg',
      minStock: 10,
    );

    test('fetchProducts berhasil memperbarui state', () async {
      // Arrange
      when(
        () => mockRepository.getProducts(),
      ).thenAnswer((_) async => [dummyProduct]);

      // Act
      await viewModel.fetchProducts();

      // Assert
      expect(viewModel.state.status, ProductStatus.success);
      expect(viewModel.state.products.length, 1);
      expect(viewModel.state.products.first.name, 'Beras');
    });

    test(
      'saveProduct (Add Baru) memanggil repository dan merefresh daftar',
      () async {
        // Arrange
        when(
          () => mockRepository.saveProduct(any(), isUpdate: false),
        ).thenAnswer((_) async => {});
        when(
          () => mockRepository.getProducts(),
        ).thenAnswer((_) async => [dummyProduct]);

        viewModel.productForm.skuController.text = 'SKU-001';
        viewModel.productForm.nameController.text = 'Beras';
        viewModel.productForm.minStockController.text = '10';

        // Act
        await viewModel.saveProduct();

        // Assert
        verify(
          () => mockRepository.saveProduct(any(), isUpdate: false),
        ).called(1);
        verify(
          () => mockRepository.getProducts(),
        ).called(1); // Refresh dipanggil
        expect(viewModel.state.status, ProductStatus.success);
        expect(viewModel.state.message, contains('Produk ditambahkan'));
      },
    );

    test(
      'adjustStock memanggil repository dan mengupdate batch list',
      () async {
        // Arrange
        when(
          () => mockRepository.adjustStock(
            productId: 'prod-1',
            type: TransactionType.inStock,
            quantity: 50.0,
            expiryDate: null,
            notes: '',
          ),
        ).thenAnswer((_) async => {});
        when(() => mockRepository.getProducts()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getActiveBatches('prod-1'),
        ).thenAnswer((_) async => []);

        viewModel.stockForm.quantityController.text = '50';

        // Act
        await viewModel.adjustStock('prod-1', TransactionType.inStock);

        // Assert
        verify(
          () => mockRepository.adjustStock(
            productId: 'prod-1',
            type: TransactionType.inStock,
            quantity: 50.0,
            expiryDate: null,
            notes: '',
          ),
        ).called(1);
        expect(viewModel.state.status, ProductStatus.success);
      },
    );
  });
}
