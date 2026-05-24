// =========================================
// widgets/custom_text_field.dart
// =========================================
// Campo de texto personalizado con validación

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int maxLines;
  final int minLines;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool showValidationIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
    this.enabled = true,
    this.showValidationIcon = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _errorText;
  bool _isObscured = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _isObscured = widget.obscureText;

    _animationController = AnimationController(
      duration: AppTheme.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _validate();
    }
  }

  void _onTextChanged() {
    if (_hasError && widget.controller != null) {
      _validate();
    }
  }

  void _validate() {
    final text = widget.controller?.text ?? '';
    final error = widget.validator?.call(text);

    setState(() {
      _errorText = error;
      _hasError = error != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            widget.label,
            style: TextStyle(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Text field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _focusNode.hasFocus ? [AppTheme.shadowSmall] : [],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _isObscured && widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              minLines: widget.minLines,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: _focusNode.hasFocus
                    ? AppColors.surfaceLight
                    : AppColors.surface,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hasError
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.divider.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hasError ? AppColors.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _focusNode.hasFocus
                            ? AppColors.primary
                            : AppColors.textMuted,
                      )
                    : null,
                suffixIcon: _buildSuffixIcon(),
              ),
            ),
          ),

          // Error message
          if (_errorText != null && _errorText!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // Si es password field
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    // Si tiene sufijo personalizado
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.primary,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    // Mostrar validación si está habilitada
    if (widget.showValidationIcon &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      if (_hasError) {
        return Icon(
          Icons.close_rounded,
          color: AppColors.error,
        );
      } else if (widget.validator != null) {
        return Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
        );
      }
    }

    return null;
  }
}
