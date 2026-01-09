import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/shared/models/ticket_model.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/modules/client/ticket/bloc/ticket_bloc.dart';
import 'package:tiko_tiko/modules/client/ticket/bloc/ticket_event.dart';
import 'package:tiko_tiko/modules/client/ticket/bloc/ticket_state.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_bloc.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_event.dart';
import 'package:tiko_tiko/modules/client/project/bloc/project_state.dart';
import 'package:tiko_tiko/shared/models/project_model.dart';
import 'package:tiko_tiko/shared/utils/status_helper.dart';
import 'package:tiko_tiko/shared/utils/ui_helpers.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  String searchQuery = "";
  String? filterStatus;
  String sortBy = "date_desc";

  @override
  void initState() {
    super.initState();
    context.read<TicketBloc>().add(const TicketLoadRequested());
    context.read<ProjectBloc>().add(ProjectLoadRequested());
  }

  List<TicketModel> _applyFilters(List<TicketModel> tickets) {
    var filtered = tickets.where((ticket) {
      final matchesSearch = ticket.subject.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter =
          filterStatus == null || ticket.status == filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();

    switch (sortBy) {
      case "date_desc":
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case "date_asc":
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case "priority_high":
        const priorityOrder = {'Haute': 3, 'Moyenne': 2, 'Basse': 1};
        filtered.sort(
          (a, b) => (priorityOrder[b.priority] ?? 0).compareTo(
            priorityOrder[a.priority] ?? 0,
          ),
        );
        break;
    }
    return filtered;
  }

  Future<void> _refreshTickets() async {
    context.read<TicketBloc>().add(const TicketLoadRequested(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          onPressed: _createTicket,
          icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
          label: const Text(
            "Nouveau ticket",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
        ),
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: RefreshIndicator(
              color: Colors.black,
              onRefresh: _refreshTickets,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    scrolledUnderElevation: 0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      "Support & Tickets",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                          setState(() {
                            filterStatus = value == "Tous" ? null : value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: "Tous", child: Text("Tous")),
                          PopupMenuItem(value: "open", child: Text("Ouvert")),
                          PopupMenuItem(
                            value: "in_progress",
                            child: Text("En cours"),
                          ),
                          PopupMenuItem(
                            value: "completed",
                            child: Text("Résolu"),
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
                            setState(() {
                              searchQuery = value;
                            });
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
                  if (state is TicketLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                  else if (state is TicketFailure)
                    SliverFillRemaining(child: Center(child: Text(state.error)))
                  else if (state is TicketLoaded)
                    _buildTicketList(state.tickets)
                  else
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketList(List<TicketModel> tickets) {
    final filteredTickets = _applyFilters(tickets);

    if (filteredTickets.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "Aucun ticket trouvé",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final ticket = filteredTickets[index];
          final ticketColor = StatusHelper.getStatusColor(ticket.status);

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
                onTap: () => _showTicketOptions(context, ticket, ticketColor),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.subject,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "T-${ticket.id} • ${_formatDate(ticket.createdAt)}",
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
                              StatusHelper.translateStatus(ticket.status),
                              style: TextStyle(
                                color: ticketColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.priority,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
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
        }, childCount: filteredTickets.length),
      ),
    );
  }

  void _showTicketOptions(
    BuildContext context,
    TicketModel ticket,
    Color color,
  ) {
    showAppModalBottomSheet(
      context: context,
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
                  context.push('/client/ticket/${ticket.id}');
                },
              ),
              if (ticket.status != "completed")
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text("Répondre au support"),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/client/ticket/${ticket.id}/chat');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _createTicket() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedPriority = 'medium';
    int? selectedProjectId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouveau ticket"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Project Selection
              BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  List<ProjectModel> projects = [];
                  if (state is ProjectLoaded) {
                    // Filter: Only validated/active projects
                    projects = state.projects.where((p) {
                      final s = p.status.toLowerCase();
                      return s == 'planned' ||
                          s == 'in_progress' ||
                          s == 'completed';
                    }).toList();
                  }

                  if (projects.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Aucun projet validé trouvé. Vous devez avoir un projet actif pour créer un ticket.",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedProjectId,
                    decoration: const InputDecoration(labelText: "Projet"),
                    items: projects
                        .map(
                          (ProjectModel p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => selectedProjectId = val,
                    validator: (val) =>
                        val == null ? "Veuillez choisir un projet" : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: "Sujet"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: "Priorité"),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text("Basse")),
                  DropdownMenuItem(value: 'medium', child: Text("Moyenne")),
                  DropdownMenuItem(value: 'high', child: Text("Haute")),
                  DropdownMenuItem(value: 'urgent', child: Text("Urgente")),
                ],
                onChanged: (val) => selectedPriority = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty ||
                  selectedProjectId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Veuillez remplir tous les champs obligatoires",
                    ),
                  ),
                );
                return;
              }

              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<TicketBloc>().add(
                  TicketCreateRequested(
                    subject: subjectController.text.trim(),
                    description: descriptionController.text.trim(),
                    clientId: authState.user.clientProfile!.id,
                    priority: selectedPriority,
                    projectId: selectedProjectId,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
}
