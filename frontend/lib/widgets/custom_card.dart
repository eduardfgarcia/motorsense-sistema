// =========================================
// widgets/custom_card.dart
// =========================================
// Card personalizado con animaciones de entrada

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum CardAnimationType { fadeIn, slideUp, scale, none }

class CustomCard extends StatefulWidget {
  final Widget child;
  final CardAnimationType animationType;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? elevation;
  final bool enableHover;
  final Duration? delay;

  const CustomCard({
    super.key,
    required this.child,
    this.animationType = CardAnimationType.fadeIn,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.enableHover = true,
    this.delay,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Setup animaciones según el tipo
    _setupAnimations();

    // Iniciar animación con delay opcional
    Future.delayed(widget.delay ?? Duration.zero, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupAnimations() {
    switch (widget.animationType) {
      case CardAnimationType.fadeIn:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        break;

      case CardAnimationType.slideUp:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        break;

      case CardAnimationType.scale:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut));
        _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.elasticOut),
        );
        break;

      case CardAnimationType.none:
        _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.linear));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.linear),
        );
        _animationController.forward();
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (widget.enableHover) {
      setState(() {
        _isHovering = hovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                boxShadow: [
                  if (_isHovering)
                    AppTheme.shadowSmall.copyWith(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  else
                    AppTheme.shadowSmall,
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.all(AppStyles.spacingM),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isHovering
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.divider.withOpacity(0.1),
                        width: _isHovering ? 2 : 1,
                      ),
                    ),
                    child: widget.isLoading
                        ? Center(
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : widget.child,
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
