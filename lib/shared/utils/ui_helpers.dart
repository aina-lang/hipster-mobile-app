import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiko_tiko/shared/blocs/ui/ui_cubit.dart';

/// Shows a modal bottom sheet and hides the bottom navigation bar while it is open.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  double? scrollControlDisabledMaxHeightRatio,
}) async {
  final uiCubit = context.read<UiCubit>();

  // Hide bottom nav bar
  uiCubit.setBottomNavBarVisibility(false);

  final result = await showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape:
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    scrollControlDisabledMaxHeightRatio:
        scrollControlDisabledMaxHeightRatio ?? 9.0 / 16.0,
  );

  // Show bottom nav bar again
  uiCubit.setBottomNavBarVisibility(true);

  return result;
}
