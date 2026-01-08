import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/invoice_bloc.dart';
import '../../../../shared/models/invoice_model.dart';
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
      backgroundColor: Colors.white,
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
                    backgroundColor: Colors.white,
                    title: Text(
                      "Documents",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                    ),
                    centerTitle: false,
                    actions: [
                      PopupMenuButton<String>(
                        tooltip: "Filtrer par statut",
                        icon: const Icon(
                          Icons.filter_list_rounded,
                          color: Colors.black,
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
                            hintText: "Rechercher un devis ou une facture...",
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

                  /// --- Contenu avec onglets ---
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final itemColor = StatusHelper.getStatusColor(item.status);

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
              onTap: () => context.push('/client/invoice-detail', extra: item),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (type == "devis" ? Colors.blue : Colors.indigo)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        type == "devis"
                            ? Icons.description_outlined
                            : Icons.receipt_long_outlined,
                        color: type == "devis" ? Colors.blue : Colors.indigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.reference,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Le ${DateFormat('dd/MM/yyyy').format(item.createdAt)}",
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
                            color: itemColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            StatusHelper.translateStatus(item.status),
                            style: TextStyle(
                              color: itemColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          NumberFormat.currency(
                            symbol: '€ ',
                            decimalDigits: 2,
                          ).format(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                            fontSize: 14,
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
      },
    );
  }
}
