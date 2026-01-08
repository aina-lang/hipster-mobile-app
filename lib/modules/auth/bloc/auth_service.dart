import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiko_tiko/shared/utils/api_response.dart';
import 'package:tiko_tiko/shared/utils/constants.dart';

class AuthService {
  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await AppConstants.dio.post(
        'login',
        data: {'email': email, 'password': password},
      );
      final body = response.data;
      print('AuthService: Login raw body: $body');

      final statusCode = body['statusCode'] ?? response.statusCode;
      print('AuthService: Using statusCode: $statusCode');

      return ApiResponse(
        message: body["message"] ?? 'Succès',
        statusCode: statusCode is int
            ? statusCode
            : int.tryParse(statusCode.toString()) ?? 500,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      print('Erreur réseau: ${e.response}');

      return ApiResponse(
        message: e.response?.data is Map<String, dynamic>
            ? (e.response?.data['message'] ?? 'Erreur inconnue')
            : (e.response?.statusMessage ?? e.message ?? 'Erreur inconnue'),
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  // (optionnel) méthode pour sauvegarder le token plus tard
  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<ApiResponse> register(
    String name,
    String email,
    String password,
    String selectedProfile,
  ) async {
    try {
      final nameParts = name.trim().split(' ');
      final firstName = nameParts[0];
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final response = await AppConstants.dio.post(
        'register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'selectedProfile': selectedProfile,
        },
      );
      final body = response.data;
      return ApiResponse(
        message: body["message"] ?? 'Succès',
        statusCode: response.statusCode!,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Erreur lors de l\'inscription',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> verifyEmail(String email, String code) async {
    try {
      final response = await AppConstants.dio.post(
        'verify-email',
        data: {'email': email, 'code': code},
      );
      final body = response.data;
      return ApiResponse(
        message: body["message"] ?? 'Succès',
        statusCode: response.statusCode!,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Code invalide ou expiré',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> resendOtp(String email) async {
    try {
      final response = await AppConstants.dio.post(
        'resend-otp',
        data: {'email': email},
      );
      return ApiResponse(
        message: response.data["message"],
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message:
            e.response?.data['message'] ?? 'Erreur lors de l\'envoi du code',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await AppConstants.dio.patch('users/me', data: data);
      final body = response.data;
      return ApiResponse(
        message: body["message"] ?? 'Profil mis à jour',
        statusCode: response.statusCode!,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Erreur mise à jour profil',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final response = await AppConstants.dio.get('users/me');
      final body = response.data;
      return ApiResponse(
        message: body["message"] ?? 'Profil récupéré',
        statusCode: response.statusCode!,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Erreur récupération profil',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await AppConstants.dio.post(
        'users/me/avatar',
        data: formData,
      );

      final body = response.data;
      return ApiResponse(
        message: body["message"] ?? 'Avatar mis à jour',
        statusCode: response.statusCode!,
        data: body["data"] ?? body,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message:
            e.response?.data['message'] ??
            'Erreur lors de l\'upload de l\'avatar',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> requestEmailChange() async {
    try {
      final response = await AppConstants.dio.post('users/me/email/request');
      return ApiResponse(
        message: response.data["message"] ?? 'Code envoyé',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message:
            e.response?.data['message'] ?? 'Erreur lors de l\'envoi du code',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> verifyCurrentEmailOtp(
    String code,
    String newEmail,
  ) async {
    try {
      final response = await AppConstants.dio.post(
        'users/me/email/verify-current',
        data: {'code': code, 'newEmail': newEmail},
      );
      return ApiResponse(
        message: response.data["message"] ?? 'Vérification réussie',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Code invalide ou expiré',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> confirmNewEmailOtp(String code) async {
    try {
      final response = await AppConstants.dio.post(
        'users/me/email/verify-new',
        data: {'code': code},
      );
      return ApiResponse(
        message: response.data["message"] ?? 'Email modifié avec succès',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Code invalide ou expiré',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> requestPasswordReset(String email) async {
    try {
      final response = await AppConstants.dio.post(
        'forgot-password',
        data: {'email': email},
      );
      return ApiResponse(
        message: response.data["message"] ?? 'Code de réinitialisation envoyé',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Erreur lors de la demande',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> verifyResetOtp(String email, String code) async {
    try {
      final response = await AppConstants.dio.post(
        'auth/forgot-password/verify',
        data: {'email': email, 'code': code},
      );
      return ApiResponse(
        message: response.data["message"] ?? 'Code vérifié',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message: e.response?.data['message'] ?? 'Code invalide',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }

  Future<ApiResponse> resetPassword(String email, String code) async {
    try {
      final response = await AppConstants.dio.post(
        'reset-password',
        data: {'email': email, 'code': code},
      );
      return ApiResponse(
        message: response.data["message"] ?? 'Mot de passe réinitialisé',
        statusCode: response.statusCode!,
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse(
        message:
            e.response?.data['message'] ?? 'Erreur lors de la réinitialisation',
        statusCode: e.response?.statusCode ?? 500,
        data: e.response?.data,
      );
    }
  }
}
