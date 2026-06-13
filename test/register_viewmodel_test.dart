// import 'package:flutter_test/flutter_test.dart';
// import 'package:stockmateapp/models/user_model.dart';
// import 'package:stockmateapp/repositories/auth_repository.dart';
// import 'package:stockmateapp/services/local/dao/user_dao.dart';
// import 'package:stockmateapp/services/remote/firebase_auth_service.dart';
// import 'package:stockmateapp/viewmodels/auth_viewmodel.dart';

// class FakeAuthRepository implements AuthRepositoryImpl {
//   bool shouldFail = false;

//   @override
//   Future<UserModel> registerAndSync(
//     String name,
//     String email,
//     String password,
//   ) async {
//     if (shouldFail) {
//       throw Exception("Email sudah terdaftar");
//     }

//     return UserModel(id: "12345", name: name, email: email);
//   }

//   @override
//   // TODO: implement firebaseService
//   FirebaseAuthService get firebaseService => throw UnimplementedError();

//   @override
//   // TODO: implement userDao
//   UserDao get userDao => throw UnimplementedError();
// }

// void main() {
//   late AuthViewModel viewModel;
//   late FakeAuthRepository fakeRepository;

//   setUp(() {
//     fakeRepository = FakeAuthRepository();

//     viewModel = AuthViewModel(repository: fakeRepository);
//   });

//   tearDown(() {
//     viewModel.dispose();
//   });

//   group('Register Form Validation', () {
//     test('Harus gagal jika nama kosong', () {
//       final result = viewModel.validateRegisterForm();

//       expect(result, false);
//       expect(viewModel.state.status, AuthStatus.error);
//       expect(viewModel.state.message, 'Nama tidak boleh kosong.');
//     });

//     test('Harus gagal jika email tidak valid', () {
//       viewModel.nameController.text = "Budi";
//       viewModel.emailController.text = "email_tidak_valid";

//       final result = viewModel.validateRegisterForm();

//       expect(result, false);
//       expect(viewModel.state.status, AuthStatus.error);
//       expect(viewModel.state.message, 'Format email tidak valid.');
//     });

//     test('Harus gagal jika password kurang dari 6 karakter', () {
//       viewModel.nameController.text = "Budi";
//       viewModel.emailController.text = "budi@gmail.com";
//       viewModel.passwordController.text = "12345";
//       viewModel.confirmPasswordController.text = "12345";

//       final result = viewModel.validateRegisterForm();

//       expect(result, false);
//       expect(viewModel.state.status, AuthStatus.error);
//       expect(viewModel.state.message, 'Kata sandi minimal 6 karakter.');
//     });

//     test('Harus gagal jika konfirmasi password tidak cocok', () {
//       viewModel.nameController.text = "Budi";
//       viewModel.emailController.text = "budi@gmail.com";
//       viewModel.passwordController.text = "password123";
//       viewModel.confirmPasswordController.text = "passwordSalah";

//       final result = viewModel.validateRegisterForm();

//       expect(result, false);
//       expect(viewModel.state.status, AuthStatus.error);
//       expect(viewModel.state.message, 'Konfirmasi kata sandi tidak cocok.');
//     });

//     test('Harus lolos validasi jika semua input benar', () {
//       viewModel.nameController.text = "Budi";
//       viewModel.emailController.text = "budi@gmail.com";
//       viewModel.passwordController.text = "password123";
//       viewModel.confirmPasswordController.text = "password123";

//       final result = viewModel.validateRegisterForm();

//       expect(result, true);
//     });
//   });

//   group('Register Process', () {
//     test(
//       'Harus berhasil register dan mengubah state menjadi authenticated',
//       () async {
//         viewModel.nameController.text = "Budi";
//         viewModel.emailController.text = "budi@gmail.com";
//         viewModel.passwordController.text = "password123";
//         viewModel.confirmPasswordController.text = "password123";

//         await viewModel.register();

//         expect(viewModel.state.status, AuthStatus.authenticated);

//         expect(viewModel.state.message, 'Registrasi berhasil.');

//         expect(viewModel.state.user, isNotNull);

//         expect(viewModel.state.user!.email, 'budi@gmail.com');
//       },
//     );

//     test('Harus gagal register jika repository melempar exception', () async {
//       fakeRepository.shouldFail = true;

//       viewModel.nameController.text = "Budi";
//       viewModel.emailController.text = "budi@gmail.com";
//       viewModel.passwordController.text = "password123";
//       viewModel.confirmPasswordController.text = "password123";

//       await viewModel.register();

//       expect(viewModel.state.status, AuthStatus.error);

//       expect(viewModel.state.message, 'Email sudah terdaftar');

//       expect(viewModel.state.user, isNull);
//     });

//     test('Tidak boleh memanggil repository jika validasi gagal', () async {
//       viewModel.nameController.text = "";
//       viewModel.emailController.text = "";
//       viewModel.passwordController.text = "";
//       viewModel.confirmPasswordController.text = "";

//       await viewModel.register();

//       expect(viewModel.state.status, AuthStatus.error);

//       expect(viewModel.state.message, 'Nama tidak boleh kosong.');

//       expect(viewModel.state.user, isNull);
//     });
//   });
// }
