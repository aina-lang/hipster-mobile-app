import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/status_helper.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<Map<String, dynamic>> allTickets = [
    {
      "id": "T-001",
      "title": "Problème de connexion",
      "status": "in_progress",
      "priority": "Haute",
      "date": DateTime(2025, 10, 10),
    },
    {
      "id": "T-002",
      "title": "Modification logo",
      "status": "completed",
      "priority": "Moyenne",
      "date": DateTime(2025, 10, 5),
    },
    {
      "id": "T-003",
      "title": "Bug sur le dashboard",
      "status": "on_hold",
      "priority": "Haute",
      "date": DateTime(2025, 10, 8),
    },
  ];

  List<Map<String, dynamic>> displayedTickets = [];
  String searchQuery = "";
  String? filterStatus;
  String sortBy = "date_desc";

  @override
  void initState() {
    super.initState();
    displayedTickets = List.from(allTickets);
  }

  void _applyFilters() {
    setState(() {
      displayedTickets = allTickets.where((ticket) {
        final matchesSearch = ticket["title"].toString().toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final matchesFilter =
            filterStatus == null || ticket["status"] == filterStatus;
        return matchesSearch && matchesFilter;
      }).toList();

      switch (sortBy) {
        case "date_desc":
          displayedTickets.sort((a, b) => b["date"].compareTo(a["date"]));
          break;
        case "date_asc":
          displayedTickets.sort((a, b) => a["date"].compareTo(b["date"]));
          break;
        case "priority_high":
          displayedTickets.sort(
            (a, b) =>
                b["priority"].toString().compareTo(a["priority"].toString()),
          );
          break;
      }
    });
  }

  Future<void> _refreshTickets() async {
    await Future.delayed(const Duration(seconds: 1));
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTicket(context),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text("Nouveau ticket"),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          color: cs.primary,
          onRefresh: _refreshTickets,
          child: CustomScrollView(
            slivers: [
              /// --- AppBar ---
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
                          "Support & Tickets",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              tooltip: "Filtrer",
                              icon: Icon(
                                Icons.filter_alt_outlined,
                                color: cs.primary,
                              ),
                              onSelected: (value) {
                                filterStatus = value == "Tous" ? null : value;
                                _applyFilters();
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "Tous",
                                  child: Text("Tous"),
                                ),
                                PopupMenuItem(
                                  value: "En attente",
                                  child: Text("En attente"),
                                ),
                                PopupMenuItem(
                                  value: "En cours",
                                  child: Text("En cours"),
                                ),
                                PopupMenuItem(
                                  value: "Résolu",
                                  child: Text("Résolu"),
                                ),
                              ],
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
                                  child: Text("Date décroissante"),
                                ),
                                PopupMenuItem(
                                  value: "date_asc",
                                  child: Text("Date croissante"),
                                ),
                                PopupMenuItem(
                                  value: "priority_high",
                                  child: Text("Priorité haute"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// --- Barre de recherche ---
              SliverPersistentHeader(
                floating: true,
                delegate: _SearchBarDelegate(
                  onChanged: (value) {
                    searchQuery = value;
                    _applyFilters();
                  },
                ),
              ),

              /// --- Liste des tickets ---
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ticket = displayedTickets[index];
                    final ticketColor = StatusHelper.getStatusColor(
                      ticket["status"],
                    );

                    return AnimatedSlide(
                      offset: const Offset(0, 0.05),
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 300),
                        child: InkWell(
                          onTap: () =>
                              _showTicketOptions(context, ticket, ticketColor),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withOpacity(
                                0.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cs.outline.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// --- Infos principales ---
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ticket["title"],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${ticket["id"]} • ${_formatDate(ticket["date"])}",
                                      style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),

                                /// --- Statut & priorité ---
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ticketColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        StatusHelper.translateStatus(
                                          ticket["status"],
                                        ),
                                        style: TextStyle(
                                          color: ticketColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ticket["priority"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: cs.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: displayedTickets.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Modal options pour chaque ticket ---
  void _showTicketOptions(
    BuildContext context,
    Map<String, dynamic> ticket,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 10,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text("Voir le détail"),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/client/ticket/${ticket["id"]}');
                },
              ),
              if (ticket["status"] != "Résolu")
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text("Répondre au support"),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/client/ticket/${ticket["id"]}/chat');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// --- Créer un ticket ---
  void _createTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nouveau ticket"),
        content: const Text(
          "Formulaire de création de ticket (à implémenter plus tard)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;
  _SearchBarDelegate({required this.onChanged});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
          decoration: InputDecoration(
            hintText: "Rechercher un ticket...",
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
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
