class UserModel {
  final int id;
  final String email;
  final String? contactEmail;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final List<String> phones;
  final String? avatarUrl;
  final bool isEmailVerified;
  final ClientProfileModel? clientProfile;
  final EmployeeProfileModel? employeeProfile;

  UserModel({
    required this.id,
    required this.email,
    this.contactEmail,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.phones = const [],
    this.avatarUrl,
    this.isEmailVerified = false,
    this.clientProfile,
    this.employeeProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      print('UserModel: RAW JSON: $json');
      final profilesMap = json['profiles'];
      print('UserModel: PROFILES MAP: $profilesMap');
      final Map<String, dynamic> profiles = profilesMap is Map
          ? Map<String, dynamic>.from(profilesMap)
          : {};

      if (profiles.containsKey('client')) {
        print('UserModel: CLIENT PROFILE JSON: ${profiles['client']}');
      }

      final user = UserModel(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        email: json['email'] ?? '',
        contactEmail: json['contactEmail'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        roles: List<String>.from(json['roles'] ?? []),
        phones: json['phones'] != null ? List<String>.from(json['phones']) : [],
        avatarUrl: json['avatarUrl'],
        isEmailVerified: json['isEmailVerified'] ?? false,
        clientProfile: profiles['client'] != null
            ? ClientProfileModel.fromJson(profiles['client'])
            : (json['clientProfile'] != null
                  ? ClientProfileModel.fromJson(json['clientProfile'])
                  : null),
        employeeProfile: profiles['employee'] != null
            ? EmployeeProfileModel.fromJson(profiles['employee'])
            : (json['employeeProfile'] != null
                  ? EmployeeProfileModel.fromJson(json['employeeProfile'])
                  : null),
      );
      print('UserModel: Successfully parsed user: ${user.email}');
      return user;
    } catch (e, stack) {
      print('UserModel ERROR during fromJson: $e');
      print(stack);
      rethrow;
    }
  }

  bool get isAdmin => roles.contains('admin');
  bool get isEmployee => roles.contains('employee');
  bool get isClient => clientProfile != null;

  bool get isProfileComplete {
    if (!isClient) return true;
    final cp = clientProfile!;

    // Validation de base commune
    final bool basicComplete =
        cp.city != null &&
        cp.city!.isNotEmpty &&
        cp.billingAddress != null &&
        cp.billingAddress!.isNotEmpty;

    if (cp.clientType == 'entreprise' || cp.clientType == 'company') {
      return basicComplete &&
          cp.companyName != null &&
          cp.companyName!.isNotEmpty;
    }

    // Pour un particulier ou si non défini, on se base sur le basic
    return basicComplete;
  }
}

class ClientProfileModel {
  final int id;
  final String? companyName;
  final int loyaltyPoints;
  final String? clientType;
  final String? siret;
  final String? tvaNumber;
  final String? website;
  final String? contactEmail;
  final String? billingAddress;
  final String? city;
  final String? zipCode;
  final String? country;
  final double cashbackTotal;

  ClientProfileModel({
    required this.id,
    this.companyName,
    required this.loyaltyPoints,
    this.clientType,
    this.siret,
    this.tvaNumber,
    this.website,
    this.contactEmail,
    this.billingAddress,
    this.city,
    this.zipCode,
    this.country,
    this.cashbackTotal = 0.0,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      companyName: json['companyName'],
      loyaltyPoints:
          int.tryParse(json['loyaltyPoints']?.toString() ?? '0') ?? 0,
      clientType: json['clientType'],
      siret: json['siret'],
      tvaNumber: json['tvaNumber'],
      website: json['website'],
      contactEmail: json['contactEmail'],
      billingAddress: json['billingAddress'],
      city: json['city'],
      zipCode: json['zipCode'],
      country: json['country'],
      cashbackTotal:
          double.tryParse(json['cashbackTotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class EmployeeProfileModel {
  final int id;
  final String poste;

  EmployeeProfileModel({required this.id, required this.poste});

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      poste: json['poste'] ?? '',
    );
  }
}
