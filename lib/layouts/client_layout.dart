import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:tiko_tiko/modules/auth/bloc/auth_bloc.dart';
import 'package:tiko_tiko/shared/blocs/notification/notification_bloc.dart';
import 'package:tiko_tiko/shared/blocs/ui/ui_cubit.dart';
import 'package:tiko_tiko/shared/blocs/ui/ui_state.dart';

class ClientLayout extends StatefulWidget {
  final Widget child;
  const ClientLayout({super.key, required this.child});

  @override
  State<ClientLayout> createState() => _ClientLayoutState();
}

class _ClientLayoutState extends State<ClientLayout> {
  int _selectedIndex = 0;
  late final NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: _selectedIndex);
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(
        NotificationLoadRequested(userId: authState.user.id),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> _routes = [
    '/client/dashboard',
    '/client/projects',
    '/client/invoices',
    '/client/tickets',
    '/client/loyalty',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final bool isComplete = authState is AuthAuthenticated
        ? authState.user.isProfileComplete
        : true;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "HIPSTER MARKETING",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        leading: isComplete
            ? BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationLoaded) {
                    unreadCount = state.unreadCount;
                  }
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: Badge(
                        label: Text(unreadCount.toString()),
                        isLabelVisible: unreadCount > 0,
                        backgroundColor: Colors.black,
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                      onPressed: () => context.push('/client/notifications'),
                    ),
                  );
                },
              )
            : null,
        actions: [
          if (isComplete)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                color: Colors.white,
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'profile') context.go('/profile');
                  if (value == 'logout') _showLogoutDialog(context);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Mon Profil",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          "Déconnexion",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: widget.child,

      /// --- Premium Animated Notch Bottom Navigation ---
      bottomNavigationBar: isComplete
          ? BlocBuilder<UiCubit, UiState>(
              builder: (context, uiState) {
                return AnimatedSlide(
                  offset: uiState.isBottomNavBarVisible
                      ? Offset.zero
                      : const Offset(0, 1.2),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    color: Colors.white,
                    showLabel: true,
                    notchColor: Colors.black,
                    removeMargins: false,
                    bottomBarWidth: 500,
                    durationInMilliSeconds: 300,
                    bottomBarItems: const [
                      BottomBarItem(
                        inActiveItem: Icon(
                          Icons.home_outlined,
                          color: Colors.black,
                        ),
                        activeItem: Icon(
                          Icons.home_filled,
                          color: Colors.white,
                        ),
                        itemLabel: 'Accueil',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(
                          Icons.folder_outlined,
                          color: Colors.black,
                        ),
                        activeItem: Icon(Icons.folder, color: Colors.white),
                        itemLabel: 'Projets',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.black,
                        ),
                        activeItem: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                        ),
                        itemLabel: 'Factures',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                        ),
                        activeItem: Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                        ),
                        itemLabel: 'Tickets',
                      ),
                      BottomBarItem(
                        inActiveItem: Icon(
                          Icons.star_outline,
                          color: Colors.black,
                        ),
                        activeItem: Icon(Icons.star, color: Colors.white),
                        itemLabel: 'Loyalty',
                      ),
                    ],
                    onTap: (index) {
                      setState(() => _selectedIndex = index);
                      context.go(_routes[index]);
                      HapticFeedback.lightImpact();
                    },
                    kIconSize: 24.0,
                    kBottomRadius: 28.0,
                  ),
                );
              },
            )
          : null,
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Se déconnecter ?"),
        content: const Text(
          "Voulez-vous vraiment vous déconnecter de votre compte ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: log out logic (FirebaseAuth.instance.signOut(), etc.)
              context.go('/login');
            },
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );
  }
}
