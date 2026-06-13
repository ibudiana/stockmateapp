part of 'auth.dart';

enum AuthStatus { idle, loading, authenticated, success, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? message;

  const AuthState({this.status = AuthStatus.idle, this.user, this.message});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? message}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }
}
