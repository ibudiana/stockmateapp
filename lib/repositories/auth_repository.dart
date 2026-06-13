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
  Future<void> resetPassword(String email);
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
  // Login lokal dulu, kalau gagal baru coba ke Firebase (hybrid approach)
  Future<UserModel> login(String email, String password) async {
    final user = await userDao.getUserByEmail(email);

    if (user == null) {
      throw Exception('Email tidak ditemukan.');
    }

    // 1. SKENARIO NORMAL: Password Lokal Benar
    if (user.password == password) {
      return user;
    }

    // 2. SKENARIO HYBRID: Password Lokal Beda (Mungkin baru reset via Firebase)
    try {
      final firebaseUser = await firebaseService.loginWithEmail(
        email,
        password,
      );

      if (firebaseUser != null) {
        await userDao.updatePassword(email, password);
        return user.copyWith(password: password);
      }
    } catch (e) {
      throw Exception('Email / Password salah.');
    }

    throw Exception('Email / Password salah.');
  }

  @override
  Future<void> resetPassword(String email) async {
    final localUser = await userDao.getUserByEmail(email);

    if (localUser == null) {
      throw Exception("Email tidak terdaftar.");
    }

    await firebaseService.resetPassword(email);
  }
}
