import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/shared/blocs/notification/notification_bloc.dart';
import 'package:tiko_tiko/shared/models/notification_model.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";
  String sortBy = "date_desc";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> items,
    String type,
  ) {
    // Basic mapping for mock tabs
    return items.where((n) {
      if (searchQuery.isNotEmpty &&
          !n.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      // Simple type matching (case insensitive or partial)
      if (type == "Devis")
        return n.type?.toLowerCase().contains("devis") ??
            n.title.toLowerCase().contains("devis");
      if (type == "Factures")
        return n.type?.toLowerCase().contains("facture") ??
            n.title.toLowerCase().contains("facture");
      if (type == "Tickets")
        return n.type?.toLowerCase().contains("ticket") ??
            n.title.toLowerCase().contains("ticket");
      if (type == "Projets")
        return n.type?.toLowerCase().contains("projet") ??
            n.title.toLowerCase().contains("projet") ||
                (n.type?.contains("project") ?? false);
      return true;
    }).toList()..sort((a, b) {
      if (sortBy == "date_desc") return b.createdAt.compareTo(a.createdAt);
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          List<NotificationModel> allNotifications = [];
          if (state is NotificationLoaded) {
            allNotifications = state.notifications;
          }

          return RefreshIndicator(
            color: cs.primary,
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<NotificationBloc>().add(
                  NotificationLoadRequested(
                    userId: authState.user.id,
                    refresh: true,
                  ),
                );
              }
            },
            child: CustomScrollView(
              slivers: [
                /// --- AppBar ---
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 80,
                  automaticallyImplyLeading: true, // Show back button
                  backgroundColor: cs.surface,
                  title: const Text(
                    "Notifications",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      tooltip: "Trier",
                      icon: Icon(Icons.sort_rounded, color: cs.primary),
                      onSelected: (value) => setState(() => sortBy = value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "date_desc",
                          child: Text("Plus récentes"),
                        ),
                        PopupMenuItem(
                          value: "date_asc",
                          child: Text("Plus anciennes"),
                        ),
                      ],
                    ),
                  ],
                ),

                /// --- Barre de recherche ---
                SliverPersistentHeader(
                  floating: true,
                  delegate: _SearchBarDelegate(
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),

                /// --- Onglets par type ---
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
                            Tab(text: "Tickets"),
                            Tab(text: "Projets"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(
                              _filterNotifications(allNotifications, "Devis"),
                              cs,
                            ),
                            _buildList(
                              _filterNotifications(
                                allNotifications,
                                "Factures",
                              ),
                              cs,
                            ),
                            _buildList(
                              _filterNotifications(allNotifications, "Tickets"),
                              cs,
                            ),
                            _buildList(
                              _filterNotifications(allNotifications, "Projets"),
                              cs,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<NotificationModel> items, ColorScheme cs) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          "Aucune notification",
          style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final notif = items[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notif.isRead
                ? cs.surfaceContainerHighest.withOpacity(0.4)
                : cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(_getIcon(notif.type ?? ""), color: cs.primary),
            title: Text(
              notif.title,
              style: TextStyle(
                fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              _formatDate(notif.createdAt),
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
            trailing: !notif.isRead
                ? Icon(Icons.circle, size: 10, color: cs.primary)
                : null,
            onTap: () {
              if (!notif.isRead) {
                context.read<NotificationBloc>().add(
                  NotificationMarkAsRead(notif.id),
                );
              }
            },
          ),
        );
      },
    );
  }

  IconData _getIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains("devis")) return Icons.description_outlined;
    if (t.contains("facture")) return Icons.receipt_long_outlined;
    if (t.contains("ticket")) return Icons.support_agent_outlined;
    if (t.contains("projet") || t.contains("project"))
      return Icons.folder_open_outlined;
    return Icons.notifications_none;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month) {
      return "Aujourd’hui • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
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
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: "Rechercher une notification...",
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
