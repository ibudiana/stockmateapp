import 'package:flutter_test/flutter_test.dart';
import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/repositories/auth_repository.dart';
import 'package:stockmateapp/services/local/dao/user_dao.dart';
import 'package:stockmateapp/services/remote/firebase_auth_service.dart';
import 'package:stockmateapp/viewmodels/auth/auth.dart';

class FakeAuthRepository implements AuthRepositoryImpl {
  bool shouldFail = false;
  bool shouldLoginFail = false;
  bool shouldResetPasswordFail = false;

  @override
  Future<UserModel> registerAndSync(
    String name,
    String username,
    String email,
    String password,
  ) async {
    if (shouldFail) {
      throw Exception("Email sudah terdaftar");
    }

    return UserModel(
      id: "12345",
      name: name,
      email: email,
      username: username,
      password: '',
      role: UserRole.admin,
    );
  }

  @override
  // TODO: implement firebaseService
  FirebaseAuthService get firebaseService => throw UnimplementedError();

  @override
  // TODO: implement userDao
  UserDao get userDao => throw UnimplementedError();

  @override
  Future<UserModel> login(String email, String password) {
    if (shouldLoginFail) {
      throw Exception("Email atau password salah");
    }

    return Future.value(
      UserModel(
        id: "12345",
        name: "Budi",
        email: email,
        username: "budi123",
        password: password,
        role: UserRole.admin,
      ),
    );
  }

  @override
  Future<void> resetPassword(String email) {
    if (shouldResetPasswordFail) {
      throw Exception("Gagal mengirim instruksi reset password");
    }
    return Future.value();
  }
}

void main() {
  late AuthViewModel viewModel;
  late FakeAuthRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    viewModel = AuthViewModel(repository: fakeRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  // PENGUJIAN: REGISTER
  group('Register Form Validation', () {
    test('nama kosong harus gagal', () {
      // ARRANGE
      viewModel.registerForm.nameController.text = '';

      // ACT
      final result = viewModel.registerForm.validate((_) {});

      // ASSERT
      expect(result, false);
    });

    test('email tidak valid harus gagal', () {
      // ARRANGE
      viewModel.registerForm.nameController.text = "Budi";
      viewModel.registerForm.emailController.text = "email_salah";

      // ACT
      final result = viewModel.registerForm.validate((_) {});

      // ASSERT
      expect(result, false);
    });

    test('valid input harus lolos', () {
      // ARRANGE
      viewModel.registerForm.nameController.text = "Budi";
      viewModel.registerForm.emailController.text = "budi@gmail.com";
      viewModel.registerForm.passwordController.text = "123456";
      viewModel.registerForm.confirmPasswordController.text = "123456";

      // ACT
      final result = viewModel.registerForm.validate((_) {});

      // ASSERT
      expect(result, true);
    });
  });

  group('Register Process', () {
    test('berhasil register', () async {
      // ARRANGE
      viewModel.registerForm.nameController.text = "Budi";
      viewModel.registerForm.emailController.text = "budi@gmail.com";
      viewModel.registerForm.passwordController.text = "123456";
      viewModel.registerForm.confirmPasswordController.text = "123456";

      // ACT
      await viewModel.register();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.user, isNotNull);
    });

    test('gagal register dari repository', () async {
      // ARRANGE
      fakeRepository.shouldFail = true;

      viewModel.registerForm.nameController.text = "Budi";
      viewModel.registerForm.emailController.text = "budi@gmail.com";
      viewModel.registerForm.passwordController.text = "123456";
      viewModel.registerForm.confirmPasswordController.text = "123456";

      // ACT
      await viewModel.register();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.user, isNull);
    });

    test('tidak register jika form invalid', () async {
      // ARRANGE
      viewModel.registerForm.nameController.text = '';

      // ACT
      await viewModel.register();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.error);
    });
  });

  // PENGUJIAN: LOGIN
  group('Login Form Validation', () {
    test('email kosong harus gagal', () {
      // ARRANGE
      viewModel.loginForm.emailController.text = '';
      viewModel.loginForm.passwordController.text = '123456';

      // ACT
      final result = viewModel.loginForm.validate((_) {});

      // ASSERT
      expect(result, false);
    });

    test('password kosong harus gagal', () {
      // ARRANGE
      viewModel.loginForm.emailController.text = 'admin@example.com';
      viewModel.loginForm.passwordController.text = '';

      // ACT
      final result = viewModel.loginForm.validate((_) {});

      // ASSERT
      expect(result, false);
    });

    test('valid input login harus lolos', () {
      // ARRANGE
      viewModel.loginForm.emailController.text = 'admin@example.com';
      viewModel.loginForm.passwordController.text = '123456';

      // ACT
      final result = viewModel.loginForm.validate((_) {});

      // ASSERT
      expect(result, true);
    });
  });

  group('Login Process', () {
    test('berhasil login', () async {
      // ARRANGE
      viewModel.loginForm.emailController.text = "admin@example.com";
      viewModel.loginForm.passwordController.text = "123456";

      // ACT
      await viewModel.login();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.user, isNotNull);
      expect(viewModel.state.user?.email, "admin@example.com");
    });

    test('gagal login dari repository (password salah)', () async {
      // ARRANGE
      fakeRepository.shouldLoginFail = true;

      viewModel.loginForm.emailController.text = "admin@example.com";
      viewModel.loginForm.passwordController.text = "salahpassword";

      // ACT
      await viewModel.login();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.user, isNull);
      expect(viewModel.state.message, isNotNull);
    });

    test('tidak memanggil login jika form invalid', () async {
      // ARRANGE
      viewModel.loginForm.emailController.text = ''; // Invalid karena kosong

      // ACT
      await viewModel.login();

      // ASSERT
      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.user, isNull);
    });
  });
}
