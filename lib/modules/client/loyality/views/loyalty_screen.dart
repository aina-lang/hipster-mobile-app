import 'package:flutter/material.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  double totalPoints = 1200;
  double totalCashback = 45000; // en Ariary
  String searchQuery = "";
  String sortBy = "date_desc";

  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Paiement facture FAC-102",
      "points": 200,
      "type": "gain",
      "date": DateTime(2025, 10, 6),
    },
    {
      "title": "Achat logo premium",
      "points": -100,
      "type": "usage",
      "date": DateTime(2025, 9, 25),
    },
    {
      "title": "Recommandation client",
      "points": 300,
      "type": "gain",
      "date": DateTime(2025, 9, 10),
    },
  ];

  List<Map<String, dynamic>> displayedTransactions = [];

  @override
  void initState() {
    super.initState();
    displayedTransactions = List.from(transactions);
  }

  void _applyFilters() {
    setState(() {
      displayedTransactions = transactions.where((t) {
        return t["title"].toString().toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
      }).toList();

      if (sortBy == "date_desc") {
        displayedTransactions.sort((a, b) => b["date"].compareTo(a["date"]));
      } else {
        displayedTransactions.sort((a, b) => a["date"].compareTo(b["date"]));
      }
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: _refresh,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
              actions: [
                PopupMenuButton<String>(
                  tooltip: "Trier",
                  icon: const Icon(Icons.sort_rounded, color: Colors.black),
                  onSelected: (value) {
                    sortBy = value;
                    _applyFilters();
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
                      searchQuery = value;
                      _applyFilters();
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${totalPoints.toStringAsFixed(0)} pts",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Total de vos points fidélité",
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
                              "${(totalCashback / 4000).toStringAsFixed(2)} €", // Assuming a conversion or just standardizing unit
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildRewardCard(
                            cs,
                            icon: Icons.discount_outlined,
                            title: "-10% sur prochain devis",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRewardCard(
                            cs,
                            icon: Icons.card_giftcard_outlined,
                            title: "Cadeau surprise 🎁",
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// --- HISTORIQUE ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final tx = displayedTransactions[i];
                  final isGain = tx["points"] > 0;
                  final statusColor = isGain ? Colors.green : Colors.red;

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
                            child: Icon(
                              isGain ? Icons.trending_up : Icons.trending_down,
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx["title"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(tx["date"]),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${isGain ? '+' : ''}${tx["points"]} pts",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: displayedTransactions.length),
              ),
            ),
          ],
        ),
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
