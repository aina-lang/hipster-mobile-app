import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enableHover; // 🌈 bonus pour desktop/web

  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.isLoading = false,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 50,
    this.borderRadius = 25,
    this.backgroundColor,
    this.textColor,
    this.enableHover = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    final fgColor = widget.textColor ?? Colors.white;

    return MouseRegion(
      onEnter: (_) {
        if (widget.enableHover) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.enableHover) setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : (_isHovered ? 1.03 : 1.0),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (widget.onPressed != null)
                BoxShadow(
                  color: Colors.black.withAlpha(
                    ((_isPressed ? 0.05 : (_isHovered ? 0.25 : 0.15)) * 255)
                        .round(),
                  ),
                  blurRadius: _isHovered ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Opacity(
            opacity: widget.onPressed == null ? 0.5 : 1.0,
            child: Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: fgColor.withAlpha((0.15 * 255).round()),
                highlightColor: fgColor.withAlpha((0.1 * 255).round()),
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) =>
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) setState(() => _isPressed = false);
                    }),
                onTapCancel: () => setState(() => _isPressed = false),
                onTap: widget.isLoading ? null : widget.onPressed,
                child: Container(
                  height: widget.height,
                  padding:
                      widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: fgColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.prefixIcon != null) ...[
                              widget.prefixIcon!,
                              if (widget.text != null) const SizedBox(width: 8),
                            ],
                            if (widget.text != null)
                              Text(
                                widget.text!,
                                style: TextStyle(color: fgColor, fontSize: 14),
                              ),
                            if (widget.suffixIcon != null) ...[
                              if (widget.text != null) const SizedBox(width: 8),
                              widget.suffixIcon!,
                            ],
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
