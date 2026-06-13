import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/remote/firebase_auth_service.dart';

abstract class AuthRepository {
  Future<UserModel> registerAndSync(
    String name,
    String username,
    String email,
    String password,
  );

  Future<UserModel> login(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService firebaseService;
  final UserDao userDao;

  AuthRepositoryImpl({required this.firebaseService, required this.userDao});

  @override
  Future<UserModel> registerAndSync(
    String name,
    String username,
    String email,
    String password,
  ) async {
    final exists = await userDao.isUsernameExists(username);

    if (exists) {
      throw Exception('Username sudah digunakan.');
    }

    final firebaseUser = await firebaseService.registerWithEmail(
      email,
      password,
    );

    if (firebaseUser == null) {
      throw Exception('Gagal membuat akun di server.');
    }

    // 2. Petakan ke UserModel
    final user = UserModel(
      id: firebaseUser.uid,
      name: name,
      username: username,
      password: password,
      email: email,
      role: UserRole.admin,
    );

    // 3. Sinkronisasi (Simpan) ke SQLite lokal via DAO
    await userDao.insertUser(user);

    return user;
  }

  @override
  // Login hanya memverifikasi data secara lokal, tanpa berinteraksi dengan Firebase Auth
  Future<UserModel> login(String email, String password) async {
    final user = await userDao.getUserByEmail(email);

    if (user == null) {
      throw Exception('Email tidak ditemukan.');
    }

    // 2. Verifikasi kata sandi secara lokal
    if (user.password != password) {
      throw Exception('Email / Password salah.');
    }

    // 3. Login sukses, kembalikan data pengguna
    return user;
  }
}
