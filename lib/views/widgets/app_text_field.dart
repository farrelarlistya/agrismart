import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? prefixText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixText,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.grey.withOpacity(0.7),
            ),
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18, color: AppColors.grey)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: AppColors.grey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            filled: true,
            fillColor: AppColors.secondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
