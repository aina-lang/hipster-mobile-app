import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/status_helper.dart';
import '../../../../shared/utils/ui_helpers.dart';

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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTicket(context),
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: const Text(
          "Nouveau ticket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: _refreshTickets,
          child: CustomScrollView(
            slivers: [
              /// --- AppBar ---
              SliverAppBar(
                pinned: true,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  "Support & Tickets",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
                actions: [
                  PopupMenuButton<String>(
                    tooltip: "Filtrer",
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.black,
                    ),
                    onSelected: (value) {
                      filterStatus = value == "Tous" ? null : value;
                      _applyFilters();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "Tous", child: Text("Tous")),
                      PopupMenuItem(
                        value: "En attente",
                        child: Text("En attente"),
                      ),
                      PopupMenuItem(value: "En cours", child: Text("En cours")),
                      PopupMenuItem(value: "Résolu", child: Text("Résolu")),
                    ],
                  ),
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
                        hintText: "Rechercher un ticket...",
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

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ticket = displayedTickets[index];
                    final ticketColor = StatusHelper.getStatusColor(
                      ticket["status"],
                    );

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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _showTicketOptions(context, ticket, ticketColor),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ticketColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.confirmation_number_outlined,
                                    color: ticketColor,
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
                                        ticket["title"],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${ticket["id"]} • ${_formatDate(ticket["date"])}",
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ticketColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        StatusHelper.translateStatus(
                                          ticket["status"],
                                        ),
                                        style: TextStyle(
                                          color: ticketColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ticket["priority"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: cs.primary,
                                        fontSize: 11,
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
    showAppModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.grey.shade300,
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
