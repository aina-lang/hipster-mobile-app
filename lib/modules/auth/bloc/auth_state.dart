part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthOnboarding extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthNeedsVerification extends AuthState {
  final String email;

  const AuthNeedsVerification(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthEmailChangeCurrentOtpSent extends AuthState {}

class AuthEmailChangeNewOtpSent extends AuthState {}

class AuthEmailChangeSuccess extends AuthState {
  final String message;
  const AuthEmailChangeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthResetOtpSent extends AuthState {
  final String email;
  const AuthResetOtpSent(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSuccess extends AuthState {}
