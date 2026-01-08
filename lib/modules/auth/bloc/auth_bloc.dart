import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_service.dart';
import 'package:tiko_tiko/shared/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// auth_bloc.dart

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    print('AuthBloc: Initializing constructor and registering handlers...');

    on<AuthStartupChecked>((event, emit) async {
      print('AuthBloc: Handling AuthStartupChecked');
      final prefs = await SharedPreferences.getInstance();
      final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

      if (!onboardingDone) {
        emit(AuthOnboarding());
        return;
      }

      final String? token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        try {
          final response = await authService.getProfile();
          if (response.statusCode == 200 || response.statusCode == 201) {
            final userData = response.data['user'] ?? response.data;
            final user = UserModel.fromJson(userData);
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthOnboardingCompletedRequested>((event, emit) async {
      print('AuthBloc: Handling AuthOnboardingCompletedRequested');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      emit(AuthUnauthenticated());
    });
    print('AuthBloc: Handlers for Startup and Onboarding registered.');

    on<AuthLoginRequested>((event, emit) async {
      try {
        emit(AuthLoading());
        final response = await authService.login(event.email, event.password);
        print('AuthBloc: Login response statusCode: ${response.statusCode}');
        print('AuthBloc: Login response message: ${response.message}');
        print('AuthBloc: Login response data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data['user'];
          if (userData == null) {
            print('AuthBloc: User data is NULL in response');
            emit(AuthFailure('Données utilisateur manquantes dans la réponse'));
            return;
          }
          print('AuthBloc: Parsing user data: $userData');

          print('AuthBloc: Response Data Keys: ${response.data.keys}');
          final token =
              response.data['accessToken'] ?? response.data['access_token'];
          final refreshToken =
              response.data['refreshToken'] ?? response.data['refresh_token'];

          if (token != null || refreshToken != null) {
            print(
              'AuthBloc: Saving tokens... Access: ${token != null ? "FOUND" : "MISSING"}, Refresh: ${refreshToken != null ? "FOUND" : "MISSING"}',
            );
            await authService.saveTokens(token ?? '', refreshToken ?? '');

            // Verification immediate
            final prefs = await SharedPreferences.getInstance();
            print(
              'AuthBloc: Immediate SharedPreferences Check - token: ${prefs.getString('token') != null}, refresh_token: ${prefs.getString('refresh_token') != null}',
            );
          } else {
            print(
              'AuthBloc: WARNING - No tokens found in response data! Checked for: accessToken, access_token, refreshToken, refresh_token',
            );
          }

          final user = UserModel.fromJson(userData);
          print('AuthBloc: User parsed successfully: ${user.email}');
          emit(AuthAuthenticated(user));
        } else if (response.statusCode == 401 &&
            response.data['needsVerification'] == true) {
          emit(AuthNeedsVerification(event.email));
        } else {
          print('AuthBloc: Login failed with message: ${response.message}');
          emit(AuthFailure(response.message));
        }
      } catch (e, stack) {
        print('AuthBloc ERROR during login: $e');
        print(stack);
        emit(AuthFailure('Erreur interne: ${e.toString()}'));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await authService.logout();
      emit(AuthUnauthenticated());
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final response = await authService.register(
        event.name,
        event.email,
        event.password,
        event.selectedProfile,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(AuthNeedsVerification(event.email));
      } else {
        emit(AuthFailure(response.message));
      }
    });

    on<AuthVerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final response = await authService.verifyEmail(event.email, event.code);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['user'] ?? response.data;

        final token =
            response.data['accessToken'] ?? response.data['access_token'];
        final refreshToken =
            response.data['refreshToken'] ?? response.data['refresh_token'];

        if (token != null) {
          await authService.saveTokens(token, refreshToken ?? '');
        }

        try {
          final user = UserModel.fromJson(userData);
          emit(AuthAuthenticated(user));
        } catch (e) {
          print("AuthBloc: Error parsing user after verification: $e");
          emit(AuthInitial()); // Fallback to login if parsing fails
        }
      } else {
        emit(AuthFailure(response.message));
      }
    });

    on<AuthResendOtpRequested>((event, emit) async {
      final response = await authService.resendOtp(event.email);
      if (response.statusCode != 200 && response.statusCode != 201) {
        emit(AuthFailure(response.message));
      }
    });

    on<AuthUpdateProfileRequested>((event, emit) async {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthLoading());
        final response = await authService.updateProfile(event.profileData);
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Le backend renvoie normalement l'objet user complet ou les données mises à jour
          final userData = response.data['user'] ?? response.data;
          try {
            final updatedUser = UserModel.fromJson(userData);
            emit(AuthAuthenticated(updatedUser));
          } catch (e) {
            print("AuthBloc: Error parsing updated user: $e");
            emit(
              AuthFailure("Erreur lors de la mise à jour des données locales"),
            );
          }
        } else {
          emit(AuthFailure(response.message));
          // On remet l'état précédent pour ne pas bloquer l'UI indéfiniment sur erreur
          emit(currentState);
        }
      }
    });

    on<AuthProfileRefreshRequested>((event, emit) async {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        // Optionnel: on peut émettre un état de chargement léger si besoin
        // Mais ici on veut juste rafraîchir en tâche de fond ou avant l'édit
        final response = await authService.getProfile();
        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data['user'] ?? response.data;
          try {
            final updatedUser = UserModel.fromJson(userData);
            emit(AuthAuthenticated(updatedUser));
          } catch (e) {
            print("AuthBloc: Error parsing refreshed user: $e");
          }
        }
      }
    });

    on<AuthAvatarUploadRequested>((event, emit) async {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        emit(AuthLoading());
        final response = await authService.uploadAvatar(event.filePath);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final userData = response.data['user'] ?? response.data;
          try {
            final updatedUser = UserModel.fromJson(userData);
            emit(AuthAuthenticated(updatedUser));
          } catch (e) {
            print("AuthBloc: Error parsing user after avatar upload: $e");
            emit(AuthFailure("Erreur lors de la mise à jour de l'avatar"));
          }
        } else {
          emit(AuthFailure(response.message));
          emit(currentState);
        }
      }
    });

    on<AuthEmailChangeRequested>((event, emit) async {
      emit(AuthLoading());
      final response = await authService.requestEmailChange();
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AuthEmailChangeCurrentOtpSent());
      } else {
        emit(AuthFailure(response.message));
      }
    });

    on<AuthEmailChangeVerifyCurrentRequested>((event, emit) async {
      emit(AuthLoading());
      final response = await authService.verifyCurrentEmailOtp(
        event.code,
        event.newEmail,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(AuthEmailChangeNewOtpSent());
      } else {
        emit(AuthFailure(response.message));
      }
    });

    on<AuthEmailChangeConfirmNewRequested>((event, emit) async {
      emit(AuthLoading());
      final response = await authService.confirmNewEmailOtp(event.code);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await authService.logout();
        emit(AuthEmailChangeSuccess(response.message));
        emit(AuthUnauthenticated());
      } else {
        emit(AuthFailure(response.message));
      }
    });
  }
}
