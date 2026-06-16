import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/models/transaction_detail_model.dart';
import 'package:stockmateapp/repositories/report_repository.dart';
import 'package:stockmateapp/viewmodels/report_viewmodel.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late ReportViewModel viewModel;
  late MockReportRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepository = MockReportRepository();
    // Default return value agar tidak error saat ViewModel diinisialisasi
    when(
      () => mockRepository.getReport(any(), any()),
    ).thenAnswer((_) async => []);

    viewModel = ReportViewModel(repository: mockRepository);
  });

  group('ReportViewModel Logic Tests', () {
    test(
      'fetchReport menghitung Total Masuk, Keluar, dan Transaksi dengan akurat',
      () async {
        // Arrange: Buat 1 stok masuk (842) dan 1 stok keluar (442) sesuai desain figma
        final dummyData = [
          TransactionDetailModel(
            transaction: StockTransactionModel(
              productId: '1',
              type: TransactionType.inStock,
              quantity: 842,
            ),
            productName: 'Barang A',
            productSku: 'A1',
          ),
          TransactionDetailModel(
            transaction: StockTransactionModel(
              productId: '2',
              type: TransactionType.outStock,
              quantity: 442,
            ),
            productName: 'Barang B',
            productSku: 'B1',
          ),
        ];
        when(
          () => mockRepository.getReport(any(), any()),
        ).thenAnswer((_) async => dummyData);

        // Act
        await viewModel.fetchReport();

        // Assert
        expect(viewModel.status, ReportStatus.success);
        expect(viewModel.transactions.length, 2);
        expect(viewModel.totalIn, 842.0); // Stok Masuk
        expect(
          viewModel.totalOut,
          442.0,
        ); // Stok Keluar (Tetap positif untuk summary)
        expect(
          viewModel.totalTransaction,
          1284.0,
        ); // 842 + 442 = Total Transaksi
      },
    );

    test('setTab mengubah tab dan memicu fetch data ulang', () async {
      // Arrange
      when(
        () => mockRepository.getReport(any(), any()),
      ).thenAnswer((_) async => []);

      // Act
      viewModel.setTab(ReportTab.yesterday);

      // Assert
      expect(viewModel.currentTab, ReportTab.yesterday);
      verify(
        () => mockRepository.getReport(any(), any()),
      ).called(greaterThan(0));
    });
  });
}
