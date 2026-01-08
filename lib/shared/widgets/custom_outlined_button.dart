import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatefulWidget {
  final String? text;
  final VoidCallback onPressed;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? textColor;
  final Color? backgroundColor;
  final bool enableHover;

  const CustomOutlinedButton({
    super.key,
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.height = 50,
    this.borderRadius = 25,
    this.borderColor,
    this.borderWidth = 2,
    this.textColor,
    this.backgroundColor,
    this.enableHover = true,
  });

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.textColor ?? theme.primaryColor;
    final border = widget.borderColor ?? theme.primaryColor;
    final bgColor = widget.backgroundColor ?? Colors.white;

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
              BoxShadow(
                color: _isHovered
                    ? theme.primaryColor.withAlpha((0.15 * 255).round())
                    : Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: _isHovered ? 10 : 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: border.withAlpha((0.1 * 255).round()),
              highlightColor: border.withAlpha((0.05 * 255).round()),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => Future.delayed(
                const Duration(milliseconds: 100),
                () => setState(() => _isPressed = false),
              ),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: widget.height,
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: _isHovered
                        ? border.withAlpha((0.9 * 255).round())
                        : border,
                    width: widget.borderWidth,
                  ),
                  color: _isHovered
                      ? bgColor.withAlpha((0.95 * 255).round())
                      : bgColor, // léger effet de hover
                ),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: color,
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
                              style: TextStyle(
                                color: color,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }
}
