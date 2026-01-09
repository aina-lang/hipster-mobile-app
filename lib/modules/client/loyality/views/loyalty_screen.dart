import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/modules/client/loyality/bloc/loyalty_bloc.dart';
import 'package:tiko_tiko/modules/client/loyality/models/loyalty_model.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  String searchQuery = "";
  String sortBy = "date_desc";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<LoyaltyBloc, LoyaltyState>(
        builder: (context, state) {
          if (state is LoyaltyLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (state is LoyaltyFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text("Erreur: ${state.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LoyaltyBloc>().add(LoyaltyRequested());
                    },
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          if (state is LoyaltyLoaded) {
            final loyalty = state.loyalty;
            final status = loyalty.currentStatus;

            // Apply filters and search to history
            List<TierHistoryModel> displayedHistory = loyalty.tierHistory.where(
              (tx) {
                return tx.projectName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              },
            ).toList();

            if (sortBy == "date_desc") {
              displayedHistory.sort(
                (a, b) => b.completedAt.compareTo(a.completedAt),
              );
            } else {
              displayedHistory.sort(
                (a, b) => a.completedAt.compareTo(b.completedAt),
              );
            }

            return RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                context.read<LoyaltyBloc>().add(LoyaltyRefreshRequested());
              },
              child: CustomScrollView(
                slivers: [
                  /// --- AppBar ---
                  SliverAppBar(
                    pinned: true,
                    scrolledUnderElevation: 0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      "Fidélité & Récompenses",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                    ),
                    centerTitle: false,
                    actions: [
                      PopupMenuButton<String>(
                        tooltip: "Trier",
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: Colors.black,
                        ),
                        onSelected: (value) {
                          setState(() {
                            sortBy = value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: "date_desc",
                            child: Text("Plus récents"),
                          ),
                          PopupMenuItem(
                            value: "date_asc",
                            child: Text("Plus anciens"),
                          ),
                        ],
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(85),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Rechercher une transaction...",
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.black54,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// --- STATISTIQUES ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.stars_rounded,
                                    color: cs.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${status.projectCount * 100} pts", // Based on backend logic: 100 pts per project
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "Niveau: ${status.tier}",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.currentReward,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Progress to next tier
                          if (status.nextTier != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Objectif: ${status.nextTier}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${status.projectsToNextTier} projets manquants",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: status.progress / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        cs.primary,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Prochain bonus: ${status.nextReward}",
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Row(
                            children: [
                              Expanded(
                                child: _buildRewardCard(
                                  cs,
                                  icon: Icons.assignment_turned_in_outlined,
                                  title:
                                      "${loyalty.totalProjects} Projets finis",
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRewardCard(
                                  cs,
                                  icon: Icons.rocket_launch_outlined,
                                  title:
                                      "${loyalty.projectsInProgress} En cours",
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// --- HISTORIQUE ---
                  if (displayedHistory.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            "Aucune transaction trouvée",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final tx = displayedHistory[i];
                          final statusColor = Colors.green;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Projet: ${tx.projectName}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(tx.completedAt),
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "+100 pts",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        tx.tierReached,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: displayedHistory.length),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRewardCard(
    ColorScheme cs, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
