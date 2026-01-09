class LoyaltyDetailModel {
  final LoyaltyClientModel client;
  final LoyaltyStatusModel currentStatus;
  final List<TierHistoryModel> tierHistory;
  final int totalProjects;
  final int projectsInProgress;

  LoyaltyDetailModel({
    required this.client,
    required this.currentStatus,
    required this.tierHistory,
    required this.totalProjects,
    required this.projectsInProgress,
  });

  factory LoyaltyDetailModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyDetailModel(
      client: LoyaltyClientModel.fromJson(json['client'] ?? {}),
      currentStatus: LoyaltyStatusModel.fromJson(json['currentStatus'] ?? {}),
      tierHistory: (json['tierHistory'] as List? ?? [])
          .map((e) => TierHistoryModel.fromJson(e))
          .toList(),
      totalProjects: json['totalProjects'] ?? 0,
      projectsInProgress: json['projectsInProgress'] ?? 0,
    );
  }
}

class LoyaltyClientModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? avatarUrl;

  LoyaltyClientModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.companyName,
    this.avatarUrl,
  });

  factory LoyaltyClientModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyClientModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'],
      lastName: json['lastName'],
      companyName: json['companyName'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

class LoyaltyStatusModel {
  final String tier;
  final int projectCount;
  final String? nextTier;
  final int projectsToNextTier;
  final String currentReward;
  final String? nextReward;
  final double progress;

  LoyaltyStatusModel({
    required this.tier,
    required this.projectCount,
    this.nextTier,
    required this.projectsToNextTier,
    required this.currentReward,
    this.nextReward,
    required this.progress,
  });

  factory LoyaltyStatusModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyStatusModel(
      tier: json['tier'] ?? 'STANDARD',
      projectCount: json['projectCount'] ?? 0,
      nextTier: json['nextTier'],
      projectsToNextTier: json['projectsToNextTier'] ?? 0,
      currentReward: json['currentReward'] ?? '',
      nextReward: json['nextReward'],
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }
}

class TierHistoryModel {
  final int projectId;
  final String projectName;
  final DateTime completedAt;
  final int projectNumber;
  final String tierReached;
  final String rewardUnlocked;

  TierHistoryModel({
    required this.projectId,
    required this.projectName,
    required this.completedAt,
    required this.projectNumber,
    required this.tierReached,
    required this.rewardUnlocked,
  });

  factory TierHistoryModel.fromJson(Map<String, dynamic> json) {
    return TierHistoryModel(
      projectId: json['projectId'] ?? 0,
      projectName: json['projectName'] ?? 'N/A',
      completedAt:
          DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
          DateTime.now(),
      projectNumber: json['projectNumber'] ?? 0,
      tierReached: json['tierReached'] ?? 'STANDARD',
      rewardUnlocked: json['rewardUnlocked'] ?? '',
    );
  }
}
