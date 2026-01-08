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
    final overlay = Overlay.of(context);

    // 🎨 Choix des couleurs/icônes
    Color bgColor;
    IconData icon;

    switch (type) {
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
      default:
        bgColor = Colors.blue.shade400;
        icon = Icons.info;
    }

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: Navigator.of(context),
    );

    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticOut,
    );

    final animation = Tween<Offset>(
      begin: Offset(fromRight ? 1.2 : -1.2, 0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    Alignment alignment;
    EdgeInsets margin;

    switch (position) {
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

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Align(
          alignment: alignment,
          child: SlideTransition(
            position: animation,
            child: Padding(
              padding: margin,
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (_) {
                  animationController.reverse();
                  overlayEntry.remove();
                  animationController.dispose();
                },
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
                            message,
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
      ),
    );

    overlay.insert(overlayEntry);
    animationController.forward();

    Future.delayed(const Duration(seconds: 4), () async {
      if (animationController.status == AnimationStatus.completed) {
        await animationController.reverse();
        overlayEntry.remove();
        animationController.dispose();
      }
    });
  }
}
