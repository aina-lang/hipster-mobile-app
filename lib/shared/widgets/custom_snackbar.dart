import 'package:flutter/material.dart';

enum SnackType { success, error, warning, info }

enum SnackPosition {
  top,
  topLeft,
  topRight,
  bottom,
  bottomLeft,
  bottomRight,
  center,
}

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.info,
    SnackPosition position = SnackPosition.bottom,
    bool fromRight = true,
  }) {
    if (!context.mounted) return;

    // 🚀 Use addPostFrameCallback to ensure the widget tree is stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final overlay = Overlay.maybeOf(context);
      if (overlay == null) return;

      late OverlayEntry overlayEntry;
      overlayEntry = OverlayEntry(
        builder: (context) => _SnackBarWidget(
          message: message,
          type: type,
          position: position,
          fromRight: fromRight,
          onDismissed: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
        ),
      );

      overlay.insert(overlayEntry);
    });
  }
}

class _SnackBarWidget extends StatefulWidget {
  final String message;
  final SnackType type;
  final SnackPosition position;
  final bool fromRight;
  final VoidCallback onDismissed;

  const _SnackBarWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.fromRight,
    required this.onDismissed,
  });

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(widget.fromRight ? 1.2 : -1.2, 0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _animationController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    await _animationController.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Choix des couleurs/icônes
    Color bgColor;
    IconData icon;

    switch (widget.type) {
      case SnackType.success:
        bgColor = Colors.green.shade400;
        icon = Icons.check_circle;
        break;
      case SnackType.error:
        bgColor = Colors.red.shade700;
        icon = Icons.error;
        break;
      case SnackType.warning:
        bgColor = Colors.orange.shade700;
        icon = Icons.warning;
        break;
      case SnackType.info:
        bgColor = Colors.blue.shade400;
        icon = Icons.info;
    }

    Alignment alignment;
    EdgeInsets margin;

    switch (widget.position) {
      case SnackPosition.top:
        alignment = Alignment.topCenter;
        margin = const EdgeInsets.only(top: 10, left: 20, right: 20);
        break;
      case SnackPosition.topLeft:
        alignment = Alignment.topLeft;
        margin = const EdgeInsets.only(top: 40, left: 20);
        break;
      case SnackPosition.topRight:
        alignment = Alignment.topRight;
        margin = const EdgeInsets.only(top: 40, right: 20);
        break;
      case SnackPosition.bottomLeft:
        alignment = Alignment.bottomLeft;
        margin = const EdgeInsets.only(bottom: 40, left: 20);
        break;
      case SnackPosition.bottomRight:
        alignment = Alignment.bottomRight;
        margin = const EdgeInsets.only(bottom: 40, right: 20);
        break;
      case SnackPosition.center:
        alignment = Alignment.center;
        margin = const EdgeInsets.all(20);
        break;
      case SnackPosition.bottom:
      default:
        alignment = Alignment.bottomCenter;
        margin = const EdgeInsets.only(bottom: 40, left: 20, right: 20);
    }

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: margin,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => widget.onDismissed(),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.25 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
