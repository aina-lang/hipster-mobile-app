import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tiko_tiko/shared/widgets/project_card.dart';
import '../../../../modules/auth/bloc/auth_bloc.dart';
// auth_state.dart is part of auth_bloc.dart, so we don't import it directly
import '../bloc/dashboard_bloc.dart';
import '../services/dashboard_repository.dart';

import '../../../../shared/models/project_model.dart';
import '../../../../shared/models/ticket_model.dart';
import '../../../../shared/models/invoice_model.dart';
import '../../../../shared/models/loyalty_model.dart';
import '../widgets/maintenance_sites_widget.dart';
import '../../../../shared/utils/status_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<MaintenanceSitesWidgetState> _maintenanceKey =
      GlobalKey<MaintenanceSitesWidgetState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Retrieve Client ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    int? clientId;
    int? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
      if (authState.user.clientProfile != null) {
        clientId = authState.user.clientProfile!.id;
      }
    }

    if (clientId == null || userId == null) {
      print('DASHBOARD_SCREEN: ERROR - clientId: $clientId, userId: $userId');
      return const Scaffold(
        body: Center(child: Text("Profil client ou utilisateur non trouvé.")),
      );
    }

    print(
      'DASHBOARD_SCREEN: Initializing with clientId: $clientId, userId: $userId',
    );

    return BlocProvider(
      create: (context) =>
          DashboardBloc(DashboardRepository())
            ..add(DashboardLoadRequested(clientId: clientId!, userId: userId!)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Erreur: ${state.message}"),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(
                          DashboardLoadRequested(
                            clientId: clientId!,
                            userId: userId!,
                            refresh: true,
                          ),
                        );
                        _maintenanceKey.currentState?.loadSites();
                      },
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              );
            } else if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    DashboardLoadRequested(
                      clientId: clientId!,
                      userId: userId!,
                      refresh: true,
                    ),
                  );
                  _maintenanceKey.currentState?.loadSites();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      scrolledUnderElevation: 0,
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: Text(
                        "Dashboard",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      centerTitle: false,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Quick Action Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.assignment_outlined,
                                  title: "Projets",
                                  number: state.data.projects.length,
                                  color: Colors.blue,
                                  onTap: () => context.push('/client/projects'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.confirmation_number_outlined,
                                  title: "Tickets",
                                  number: state.data.tickets.length,
                                  color: Colors.orange,
                                  onTap: () => context.push('/client/tickets'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.receipt_long_outlined,
                                  title: "Factures & Devis",
                                  number: state.data.invoices.length,
                                  color: Colors.pink,
                                  onTap: () => context.push('/client/invoices'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildQuickActionCard(
                                  icon: Icons.workspace_premium_rounded,
                                  title: "Fidélité",
                                  number: state.data.loyalty?.projectCount ?? 0,
                                  color: Colors.purple,
                                  onTap: () => context.push('/client/rewards'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Maintenance Sites Section
                          MaintenanceSitesWidget(
                            key: _maintenanceKey,
                            clientId: clientId!,
                          ),
                          const SizedBox(height: 24),

                          // Projects Timeline
                          if (state.data.projects.isNotEmpty) ...[
                            Text(
                              "Projets récents",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildProjectTimeline(state.data.projects),
                            const SizedBox(height: 24),
                          ],

                          // Tickets List
                          if (state.data.tickets.isNotEmpty) ...[
                            Text(
                              "Tickets récents",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTicketsList(state.data.tickets),
                            const SizedBox(height: 24),
                          ],

                          // Invoices List
                          if (state.data.invoices.isNotEmpty) ...[
                            Text(
                              "Factures à payer",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInvoicesList(state.data.invoices),
                            const SizedBox(height: 24),
                          ],

                          // Rewards / Loyalty
                          if (state.data.loyalty != null) ...[
                            Text(
                              "Mes Récompenses",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRewardsCard(state.data.loyalty!),
                            const SizedBox(height: 24),
                          ],
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("État inconnu"));
          },
        ),
      ),
    );
  }

  // ---------------- QUICK ACTION CARDS ----------------
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required int number,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              number.toString(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PROJECT TIMELINE ----------------
  Widget _buildProjectTimeline(List<ProjectModel> projects) {
    // Filter to show only 3 levels: Pending, In Progress (planned/in_progress/on_hold), and Completed
    // Exclude refused and canceled projects from primary dashboard view
    final filteredProjects = projects.where((p) {
      final s = p.status.toLowerCase();
      return s == 'pending' ||
          s == 'planned' ||
          s == 'in_progress' ||
          s == 'on_hold' ||
          s == 'completed';
    }).toList();

    // Only show top 3 recent projects
    final recentProjects = filteredProjects.length > 3
        ? filteredProjects.sublist(0, 3)
        : filteredProjects;

    return Column(
      children: recentProjects.asMap().entries.map((entry) {
        return ProjectCard(project: entry.value, index: entry.key);
      }).toList(),
    );
  }

  // ---------------- TICKETS ----------------
  Widget _buildTicketsList(List<TicketModel> tickets) {
    final recentTickets = tickets.length > 3 ? tickets.sublist(0, 3) : tickets;

    return Column(
      children: recentTickets.map((t) {
        final statusColor = StatusHelper.getStatusColor(t.status);
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
              onTap: () => context.push('/client/ticket/${t.id}'),
              borderRadius: BorderRadius.circular(16),
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
                        Icons.confirmation_number_outlined,
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
                            t.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Créé le: ${_formatDate(t.createdAt)}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        StatusHelper.translateStatus(t.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- INVOICES ----------------
  Widget _buildInvoicesList(List<InvoiceModel> invoiceList) {
    // Filter to show only real invoices (not quotes)
    final invoices = invoiceList.where((i) => i.type == 'invoice').toList();

    final recentInvoices = invoices.length > 3
        ? invoices.sublist(0, 3)
        : invoices;

    return Column(
      children: recentInvoices.map((i) {
        final statusColor = StatusHelper.getStatusColor(i.status);
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
              onTap: () => context.push('/client/invoices'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.request_quote_outlined,
                        color: Colors.indigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i.reference,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${i.amount} € • ${i.dueDate != null ? _formatDate(i.dueDate!) : 'Pas de date'}",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        StatusHelper.translateStatus(i.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // ---------------- REWARDS ----------------
  Widget _buildRewardsCard(LoyaltyModel loyalty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.black87, Colors.black54],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loyalty.tier.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Points Fidélité",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "${loyalty.projectCount} Projets",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (loyalty.nextTier != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: loyalty.progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prochain tier: ${loyalty.nextTier}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  "Encore ${loyalty.projectsToNextTier} projets",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          if (loyalty.currentReward != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.redeem_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loyalty.currentReward!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
