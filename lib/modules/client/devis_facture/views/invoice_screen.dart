import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/invoice_bloc.dart';
import '../../../../shared/models/invoice_model.dart';
import '../../../../shared/utils/ui_helpers.dart';
import '../../../../shared/services/file_service.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<InvoiceModel> _filterList(List<InvoiceModel> source) {
    var result = source.where((item) {
      final matchesSearch = item.reference.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter = filterStatus == null || item.status == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    switch (sortBy) {
      case "date_desc":
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case "date_asc":
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case "amount_desc":
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case "amount_asc":
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return result;
  }

  Future<void> _refreshData() async {
    context.read<InvoiceBloc>().add(InvoiceLoadRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<InvoiceBloc, InvoiceState>(
        builder: (context, state) {
          if (state is InvoiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InvoiceFailure) {
            return Center(child: Text("Erreur: ${state.error}"));
          }
          if (state is InvoiceLoaded) {
            final allQuotes = state.invoices
                .where((i) => i.type == 'quote')
                .toList();
            final allInvoices = state.invoices
                .where((i) => i.type == 'invoice')
                .toList();

            final displayedQuotes = _filterList(allQuotes);
            final displayedInvoices = _filterList(allInvoices);

            return RefreshIndicator(
              color: cs.primary,
              onRefresh: _refreshData,
              child: CustomScrollView(
                slivers: [
                  /// --- AppBar ---
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    scrolledUnderElevation: 0,
                    backgroundColor: cs.surface,
                    title: Text(
                      "DOCUMENTS",
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      PopupMenuButton<String>(
                        tooltip: "Filtrer par statut",
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: cs.primary,
                        ),
                        onSelected: (value) {
                          setState(() {
                            filterStatus = value == "Tous" ? null : value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: "Tous", child: Text("Tous")),
                          PopupMenuItem(
                            value: "pending",
                            child: Text("En attente"),
                          ),
                          PopupMenuItem(value: "paid", child: Text("Payée")),
                          PopupMenuItem(
                            value: "accepted",
                            child: Text("Accepté"),
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        tooltip: "Trier",
                        icon: Icon(Icons.sort_rounded, color: cs.primary),
                        onSelected: (value) {
                          setState(() {
                            sortBy = value;
                          });
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

                  /// --- Barre de recherche ---
                  SliverPersistentHeader(
                    floating: true,
                    delegate: _SearchBarDelegate(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
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
                              shape: RoundedRectangleBorder(
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
                              _buildList(displayedInvoices, cs, "factures"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildList(List<InvoiceModel> items, ColorScheme cs, String type) {
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
        final itemColor = StatusHelper.getStatusColor(item.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            title: Text(
              item.reference,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              "Créé le ${DateFormat('dd/MM/yyyy').format(item.createdAt)}",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
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
                    StatusHelper.translateStatus(item.status),
                    style: TextStyle(
                      color: itemColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  NumberFormat.currency(
                    symbol: 'Ar ',
                    decimalDigits: 0,
                  ).format(item.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            onTap: () => _showInvoiceOptions(context, item),
          ),
        );
      },
    );
  }

  void _showInvoiceOptions(BuildContext context, InvoiceModel item) {
    final cs = Theme.of(context).colorScheme;

    showAppModalBottomSheet(
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
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await FileService().downloadAndOpenFile(
                      '/invoices/${item.id}/pdf',
                      '${item.type}_${item.reference}.pdf',
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                  }
                },
              ),
              if (item.status == "pending")
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
                  context.push('/client/invoice/${item.id}');
                },
              ),
            ],
          ),
        );
      },
    );
  }
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
              borderSide: BorderSide.none,
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
