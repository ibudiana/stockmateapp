import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockmateapp/repositories/report_repository.dart';
import 'package:stockmateapp/services/local/dao/report_dao.dart';

class MockReportDao extends Mock implements ReportDao {}

void main() {
  late ReportRepository repository;
  late MockReportDao mockDao;

  // Daftarkan fallback value untuk tipe data DateTime agar mocktail.any() tidak error
  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockDao = MockReportDao();
    repository = ReportRepository(reportDao: mockDao);
  });

  group('ReportRepository Tests', () {
    test(
      'getReport menormalisasi rentang waktu menjadi awal dan akhir hari',
      () async {
        // Arrange
        when(
          () => mockDao.getTransactionsByDateRange(any(), any()),
        ).thenAnswer((_) async => []);

        // Act: User memilih filter menggunakan waktu acak (misal jam 10:30 sampai 15:45)
        final start = DateTime(2026, 11, 1, 10, 30);
        final end = DateTime(2026, 11, 15, 15, 45);

        await repository.getReport(start, end);

        // Assert: DAO harus menerima waktu yang di-reset jamnya
        final expectedStart = DateTime(2026, 11, 1, 0, 0, 0); // 00:00:00
        final expectedEnd = DateTime(2026, 11, 15, 23, 59, 59); // 23:59:59

        verify(
          () => mockDao.getTransactionsByDateRange(expectedStart, expectedEnd),
        ).called(1);
      },
    );
  });
}
