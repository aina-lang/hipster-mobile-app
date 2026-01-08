import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/status_helper.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";
  String? filterStatus;
  String sortBy = "date_desc";

  final List<Map<String, dynamic>> quotes = [
    {
      "id": "DEV-001",
      "title": "Création site web",
      "amount": 450000,
      "status": "on_hold",
      "date": DateTime(2025, 10, 2),
    },
    {
      "id": "DEV-002",
      "title": "Campagne Google Ads",
      "amount": 300000,
      "status": "completed",
      "date": DateTime(2025, 9, 28),
    },
  ];

  final List<Map<String, dynamic>> invoices = [
    {
      "id": "FAC-101",
      "title": "Logo & Identité visuelle",
      "amount": 200000,
      "status": "paid",
      "date": DateTime(2025, 9, 18),
    },
    {
      "id": "FAC-102",
      "title": "Community Management",
      "amount": 150000,
      "status": "on_hold",
      "date": DateTime(2025, 10, 5),
    },
  ];

  List<Map<String, dynamic>> displayedQuotes = [];
  List<Map<String, dynamic>> displayedInvoices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    displayedQuotes = List.from(quotes);
    displayedInvoices = List.from(invoices);
  }

  void _applyFilters() {
    setState(() {
      List<Map<String, dynamic>> filterList(List<Map<String, dynamic>> source) {
        var result = source.where((item) {
          final matchesSearch = item["title"].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final matchesFilter =
              filterStatus == null || item["status"] == filterStatus;
          return matchesSearch && matchesFilter;
        }).toList();

        switch (sortBy) {
          case "date_desc":
            result.sort((a, b) => b["date"].compareTo(a["date"]));
            break;
          case "date_asc":
            result.sort((a, b) => a["date"].compareTo(b["date"]));
            break;
          case "amount_desc":
            result.sort((a, b) => b["amount"].compareTo(a["amount"]));
            break;
          case "amount_asc":
            result.sort((a, b) => a["amount"].compareTo(b["amount"]));
            break;
        }
        return result;
      }

      displayedQuotes = filterList(quotes);
      displayedInvoices = filterList(invoices);
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          color: cs.primary,
          onRefresh: _refreshData,
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
                          "Devis & Factures",
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
                                  value: "Payée",
                                  child: Text("Payée"),
                                ),
                                PopupMenuItem(
                                  value: "Accepté",
                                  child: Text("Accepté"),
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
                                  value: "amount_desc",
                                  child: Text("Montant décroissant"),
                                ),
                                PopupMenuItem(
                                  value: "amount_asc",
                                  child: Text("Montant croissant"),
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

              /// --- Contenu avec onglets ---
              SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: _tabController,
                        indicator: ShapeDecoration(
                          color: cs.primary,
                          shape:
                              // const StadiumBorder(), // ou RoundedRectangleBorder pour coins arrondis
                              // shape:
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: cs.onSurface.withOpacity(0.7),
                        tabs: const [
                          Tab(text: "Devis"),
                          Tab(text: "Factures"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(displayedQuotes, cs, "devis"),
                          _buildList(displayedInvoices, cs, "facture"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<Map<String, dynamic>> items,
    ColorScheme cs,
    String type,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "Aucun $type trouvé",
          style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final itemColor = StatusHelper.getStatusColor(item["status"]);

        return AnimatedSlide(
          offset: const Offset(0, 0.1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 400),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset.zero),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Text(
                  item["title"],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  "${item["id"]} • ${_formatDate(item["date"])}",
                  style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: itemColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        StatusHelper.translateStatus(item["status"]),
                        style: TextStyle(
                          color: itemColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${item["amount"]} Ar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showInvoiceOptions(context, item),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInvoiceOptions(BuildContext context, Map<String, dynamic> item) {
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
            runSpacing: 12,
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
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text("Télécharger le PDF"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implémenter téléchargement PDF
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Téléchargement du PDF...")),
                  );
                },
              ),
              if (item["status"] == "En attente")
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text("Payer maintenant"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Stripe integration ici
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Redirection vers Stripe..."),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text("Voir les détails"),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/client/invoice/${item["id"]}');
                },
              ),
            ],
          ),
        );
      },
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
            hintText: "Rechercher un devis ou une facture...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: cs.outline.withAlpha((0.2 * 255).round()),
              ),
            ),
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
