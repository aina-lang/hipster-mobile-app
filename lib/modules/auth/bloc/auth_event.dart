part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String selectedProfile;

  const AuthRegisterRequested(
    this.name,
    this.email,
    this.password,
    this.selectedProfile,
  );

  @override
  List<Object> get props => [name, email, password, selectedProfile];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyOtpRequested(this.email, this.code);

  @override
  List<Object?> get props => [email, code];
}

class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final Map<String, dynamic> profileData;

  const AuthUpdateProfileRequested(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class AuthProfileRefreshRequested extends AuthEvent {}

class AuthAvatarUploadRequested extends AuthEvent {
  final String filePath;

  const AuthAvatarUploadRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class AuthStartupChecked extends AuthEvent {}

class AuthOnboardingCompletedRequested extends AuthEvent {}

class AuthEmailChangeRequested extends AuthEvent {}

class AuthEmailChangeVerifyCurrentRequested extends AuthEvent {
  final String code;
  final String newEmail;

  const AuthEmailChangeVerifyCurrentRequested({
    required this.code,
    required this.newEmail,
  });

  @override
  List<Object?> get props => [code, newEmail];
}

class AuthEmailChangeConfirmNewRequested extends AuthEvent {
  final String code;

  const AuthEmailChangeConfirmNewRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthVerifyResetOtpRequested extends AuthEvent {
  final String email;
  final String code;
  const AuthVerifyResetOtpRequested({required this.email, required this.code});
  @override
  List<Object?> get props => [email, code];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String password;
  const AuthResetPasswordRequested({
    required this.email,
    required this.code,
    required this.password,
  });
  @override
  List<Object?> get props => [email, code, password];
}
