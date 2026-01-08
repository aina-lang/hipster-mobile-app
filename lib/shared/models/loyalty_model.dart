class LoyaltyModel {
  final int projectCount;
  final String tier;
  final String? nextTier;
  final int projectsToNextTier;
  final double progress;
  final String? currentReward;
  final String? nextReward;

  LoyaltyModel({
    required this.projectCount,
    required this.tier,
    this.nextTier,
    required this.projectsToNextTier,
    required this.progress,
    this.currentReward,
    this.nextReward,
  });

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) {
    // Loyalty data sometimes comes directly, or nested in 'data'
    // But since DashboardRepository passes response.data, let's just be safe.
    // If the json itself has a 'data' field that looks like loyalty, use it.
    final data = json['data'] is Map ? json['data'] : json;

    return LoyaltyModel(
      projectCount: int.tryParse(data['projectCount']?.toString() ?? '0') ?? 0,
      tier: data['tier'] ?? 'N/A',
      nextTier: data['nextTier'],
      projectsToNextTier:
          int.tryParse(data['projectsToNextTier']?.toString() ?? '0') ?? 0,
      progress: double.tryParse(data['progress']?.toString() ?? '0') ?? 0.0,
      currentReward: data['currentReward'],
      nextReward: data['nextReward'],
    );
  }
}
