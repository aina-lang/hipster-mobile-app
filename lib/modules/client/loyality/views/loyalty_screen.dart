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
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        color: cs.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            /// --- HEADER ---
            SliverAppBar(
              pinned: true,
              expandedHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: cs.surface,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fidélité & Récompenses",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: "Trier",
                        icon: Icon(Icons.sort_rounded, color: cs.primary),
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
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: cs.primary,
                            size: 36,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$totalPoints pts",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                                Text(
                                  "Total de vos points fidélité",
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.6),
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
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${totalCashback.toStringAsFixed(0)} Ar",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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

            /// --- BARRE DE RECHERCHE ---
            SliverPersistentHeader(
              floating: true,
              delegate: _SearchBarDelegate(
                onChanged: (value) {
                  searchQuery = value;
                  _applyFilters();
                },
              ),
            ),

            /// --- HISTORIQUE ---
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final tx = displayedTransactions[i];
                  final isGain = tx["points"] > 0;

                  return AnimatedSlide(
                    offset: const Offset(0, 0.1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isGain
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            child: Icon(
                              isGain ? Icons.trending_up : Icons.trending_down,
                              color: isGain ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            tx["title"],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            _formatDate(tx["date"]),
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          trailing: Text(
                            "${isGain ? '+' : ''}${tx["points"]} pts",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isGain ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
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

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;
  _SearchBarDelegate({required this.onChanged});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: "Rechercher une transaction...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(14),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72;
  @override
  double get minExtent => 72;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
