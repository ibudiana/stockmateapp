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
}
