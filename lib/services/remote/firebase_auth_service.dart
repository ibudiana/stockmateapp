import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  Future<User?> registerWithEmail(String email, String password) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

  Future<User?> loginWithEmail(String email, String password) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("Email tidak terdaftar.");
      } else {
        throw Exception("Gagal mengirim instruksi reset password.");
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
