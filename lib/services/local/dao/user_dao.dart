import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/services/local/database.dart';

class UserDao {
  final DatabaseService _dbService;

  UserDao({required DatabaseService dbService}) : _dbService = dbService;

  // Simpan user ke SQLite
  Future<int> insertUser(UserModel user) async {
    final db = await _dbService.database;
    return await db.insert('users', user.toMap());
  }

  Future<dynamic> getUserById(String s) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [s],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<dynamic> isUsernameExists(String username) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<dynamic> getUserByEmail(String email) async {
    final db = await _dbService.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // update password
  Future<int> updatePassword(String email, String newPassword) async {
    final db = await _dbService.database;
    return await db.update(
      'users',
      {'password': newPassword, 'updated_at': DateTime.now().toIso8601String()},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Mengambil semua user dari tabel users
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  // Memperbarui record user berdasarkan ID
  Future<void> updateUser(UserModel user) async {
    final db = await _dbService.database;
    await db.update(
      'users',
      user.toMap(), // Pastikan UserModel memiliki toMap() atau toJson()
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
