class MaintenanceSiteModel {
  final int id;
  final String url;
  final String? description;
  final String? lastMaintenanceDate;

  MaintenanceSiteModel({
    required this.id,
    required this.url,
    this.description,
    this.lastMaintenanceDate,
  });

  factory MaintenanceSiteModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceSiteModel(
      id: json['id'] as int,
      url: json['url'] as String,
      description: json['description'] as String?,
      lastMaintenanceDate: json['lastMaintenanceDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
      'lastMaintenanceDate': lastMaintenanceDate,
    };
  }
}

class MaintenanceSitesResponse {
  final List<MaintenanceSiteModel> sites;
  final String message;

  MaintenanceSitesResponse({required this.sites, required this.message});

  factory MaintenanceSitesResponse.fromJson(Map<String, dynamic> json) {
    // Top-level 'data' from the API interceptor
    final rawData = json['data'];

    // Safely cast to Map
    final Map<String, dynamic> data = (rawData is Map)
        ? Map<String, dynamic>.from(rawData)
        : {};

    // Check if there is a nested 'data' (in case of double wrapping that might still occur)
    final nestedData = data['data'];
    final Map<String, dynamic> effectiveData = (nestedData is Map)
        ? Map<String, dynamic>.from(nestedData)
        : data;

    // Safely extract sites list
    final sitesJson = effectiveData['sites'] as List<dynamic>? ?? [];

    return MaintenanceSitesResponse(
      sites: sitesJson
          .map(
            (site) =>
                MaintenanceSiteModel.fromJson(site as Map<String, dynamic>),
          )
          .toList(),
      message: effectiveData['message']?.toString() ?? '',
    );
  }
}
