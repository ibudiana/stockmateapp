import 'package:flutter_test/flutter_test.dart';
import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/local/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;
  late UserDao dao;

  setUp(() {
    dbService = DatabaseService(inMemory: true);
  });

  tearDown(() async {
    final db = await dbService.database;
    await db.close();
  });

  // Test untuk memastikan UserDao bisa menyimpan data user ke SQLite dengan benar
  test('Can Insert User ke SQLite', () async {
    // Arrange
    dao = UserDao(dbService: dbService);
    final user = UserModel(
      id: '12345',
      name: 'Wayan Budiana',
      username: 'ibudiana',
      password: 'password123',
      email: 'budi@gmail.com',
      role: UserRole.admin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    // Act
    await dao.insertUser(user);
    // Assert
    final result = await dao.getUserById('12345');
    expect(result, isNotNull);
    expect(result!.email, 'budi@gmail.com');
    expect(result!.name, 'Wayan Budiana');
    expect(result!.username, 'ibudiana');
    expect(result!.role, UserRole.admin);
    expect(result!.createdAt, isNotNull);
    expect(result!.updatedAt, isNotNull);
  });
}
