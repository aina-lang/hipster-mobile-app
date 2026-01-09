import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tiko_tiko/shared/blocs/notification/notification_bloc.dart';
import 'package:tiko_tiko/shared/models/notification_model.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/services/file_service.dart';
import 'package:tiko_tiko/shared/widgets/custom_snackbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";

  // Categories derived from model helpers
  final List<String> _categories = [
    "Tout",
    "Devis",
    "Factures",
    "Tickets",
    "Projets",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> items,
    String category,
  ) {
    return items.where((n) {
      // 1. Search Filter
      if (searchQuery.isNotEmpty &&
          !n.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !n.message.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      // 2. Category Filter
      if (category == "Tout") return true;
      if (category == "Devis") return n.category == 'devis';
      if (category == "Factures") return n.category == 'facture';
      if (category == "Tickets") return n.category == 'ticket';
      if (category == "Projets") return n.category == 'projet';

      return true;
    }).toList();
  }

  void _markAllAsRead(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        NotificationMarkAllAsRead(authState.user.id),
      );
      AppSnackBar.show(
        context,
        "Toutes les notifications ont été marquées comme lues",
        position: SnackPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          List<NotificationModel> allNotifications = [];

          if (state is NotificationLoaded) {
            allNotifications = state.notifications;
          }

          final unreadCount = allNotifications.where((n) => !n.isRead).length;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: Text(
                  "Notifications",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                actions: [
                  if (unreadCount > 0)
                    IconButton(
                      tooltip: "Tout marquer comme lu",
                      icon: const Icon(
                        Icons.done_all_rounded,
                        color: Colors.black,
                      ),
                      onPressed: () => _markAllAsRead(context),
                    ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(145),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Rechercher une notification...",
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
                      // Tab Bar
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabAlignment: TabAlignment.start,
                          indicator: ShapeDecoration(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: cs.onSurface.withOpacity(0.7),
                          tabs: _categories
                              .map((cat) => Tab(text: cat))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: RefreshIndicator(
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
              color: Colors.black,
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Controlled by chips
                children: _categories.map((category) {
                  final filtered = _filterNotifications(
                    allNotifications,
                    category,
                  );
                  return _buildNotificationList(filtered, cs);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationModel> notifications,
    ColorScheme cs,
  ) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune notification",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return _buildNotificationCard(context, notif, cs)
            .animate()
            .fadeIn(duration: 300.ms, delay: (50 * index).ms)
            .slideX(begin: 0.1, duration: 300.ms);
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notif,
    ColorScheme cs,
  ) {
    final isUnread = !notif.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isUnread) {
              context.read<NotificationBloc>().add(
                NotificationMarkAsRead(notif.id),
              );
            }
            // Navigate based on type
            _handleNavigation(context, notif);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          notif.category,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(notif.category),
                        color: _getCategoryColor(notif.category),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontWeight: isUnread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(notif.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Contextual Action Button
                if (_hasAction(notif)) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      if (isUnread) {
                        context.read<NotificationBloc>().add(
                          NotificationMarkAsRead(notif.id),
                        );
                      }
                      _handleAction(context, notif);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getActionLabel(notif),
                            style: TextStyle(
                              color: _getCategoryColor(notif.category),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: _getCategoryColor(notif.category),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Logic Helpers ---

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'devis':
        return Colors.teal;
      case 'facture':
        return Colors.indigo;
      case 'ticket':
        return Colors.orange;
      case 'projet':
        return Colors.blueGrey;
      default:
        return Colors.black;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'devis':
        return Icons.receipt_long;
      case 'facture':
        return Icons.request_quote_outlined;
      case 'ticket':
        return Icons.support_agent;
      case 'projet':
        return Icons.folder_open;
      default:
        return Icons.notifications_none;
    }
  }

  // --- Action Logic ---

  bool _hasAction(NotificationModel notif) {
    if (notif.category == 'devis' && notif.invoiceId != null) return true;
    if (notif.category == 'facture' && notif.invoiceId != null) return true;
    if (notif.category == 'ticket') return true; // Always navigate to tickets
    if (notif.category == 'projet' && notif.projectId != null) return true;
    return false;
  }

  String _getActionLabel(NotificationModel notif) {
    switch (notif.category) {
      case 'devis':
        return "TÉLÉCHARGER LE DEVIS";
      case 'facture':
        return "TÉLÉCHARGER LA FACTURE";
      case 'ticket':
        return "VOIR LE TICKET";
      case 'projet':
        return "VOIR LE PROJET";
      default:
        return "VOIR";
    }
  }

  void _handleNavigation(BuildContext context, NotificationModel notif) {
    if (notif.category == 'ticket') {
      if (notif.data?['ticketId'] != null) {
        context.push('/client/ticket/${notif.data!['ticketId']}');
      } else {
        context.push('/client/tickets');
      }
    } else if (notif.category == 'projet' && notif.projectId != null) {
      context.push('/client/projects/${notif.projectId}');
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    NotificationModel notif,
  ) async {
    switch (notif.category) {
      case 'devis':
      case 'facture':
        if (notif.invoiceId != null) {
          AppSnackBar.show(
            context,
            "Téléchargement du document...",
            position: SnackPosition.top,
          );
          try {
            await FileService().downloadAndOpenFile(
              '/invoices/${notif.invoiceId}/pdf',
              'document_${notif.invoiceId}.pdf',
            );
          } catch (e) {
            AppSnackBar.show(
              context,
              "Erreur lors du téléchargement: $e",
              type: SnackType.error,
            );
          }
        }
        break;
      case 'ticket':
        if (notif.data?['ticketId'] != null) {
          context.push('/client/ticket/${notif.data!['ticketId']}');
        } else {
          context.push('/client/tickets');
        }
        break;
      case 'projet':
        if (notif.projectId != null) {
          context.push('/client/projects/${notif.projectId}');
        }
        break;
    }
  }

  String _formatDate(DateTime date) {
    if (date.day == DateTime.now().day) {
      return "Aujourd'hui, ${DateFormat('HH:mm').format(date)}";
    }
    return DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(date);
  }
}
