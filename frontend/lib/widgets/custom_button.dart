// =========================================
// widgets/custom_button.dart
// =========================================
// Botón personalizado con animaciones y estados

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.isEnabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _animationController.reverse();
  }

  void _onHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) {
      return AppColors.disabled;
    }

    switch (widget.type) {
      case ButtonType.primary:
        return _isHovering ? AppColors.primaryDark : AppColors.primary;
      case ButtonType.secondary:
        return _isHovering ? AppColors.secondaryDark : AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    if (!widget.isEnabled) {
      return AppColors.textMuted;
    }

    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.textPrimary;
      case ButtonType.secondary:
        return AppColors.textPrimary;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  BorderSide _getBorderSide() {
    if (!widget.isEnabled) {
      return BorderSide(color: AppColors.disabled, width: 1);
    }

    switch (widget.type) {
      case ButtonType.outline:
        return BorderSide(
          color: _isHovering ? AppColors.primaryDark : AppColors.primary,
          width: 2,
        );
      default:
        return BorderSide.none;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getTextSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: OpacityTransition(
            opacity: _opacityAnimation,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isEnabled && !widget.isLoading
                      ? widget.onPressed
                      : null,
                  splashColor: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: _getPadding(),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(),
                      border: Border(
                        top: _getBorderSide(),
                        bottom: _getBorderSide(),
                        left: _getBorderSide(),
                        right: _getBorderSide(),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: widget.isEnabled && !widget.isLoading
                          ? [AppTheme.shadowSmall]
                          : [],
                    ),
                    child: widget.isLoading
                        ? SizedBox(
                            width: _getTextSize() + 8,
                            height: _getTextSize() + 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getForegroundColor(),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: _getForegroundColor(),
                                  size: _getTextSize() + 2,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: TextStyle(
                                  color: _getForegroundColor(),
                                  fontSize: _getTextSize(),
                                  fontWeight: FontWeight.w600,
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
  }
}

// Helper widget para Opacity animation
class OpacityTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> opacity;

  const OpacityTransition({
    Key? key,
    required this.child,
    required this.opacity,
  }) : super(key: key, listenable: opacity);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.value,
      child: child,
    );
  }
}
