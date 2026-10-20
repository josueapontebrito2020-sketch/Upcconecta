import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_extensions.dart';
import 'app_input_decoration.dart';

/// Campo de texto con el estilo de UpcConecta. Si [isPassword] es true,
/// oculta el texto y muestra un botón para verlo.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.prefixText,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  /// Altura inicial en líneas (para textos largos, como una descripción).
  final int? minLines;
  final int? maxLength;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final passwordToggle = IconButton(
      tooltip: _obscured ? context.l10n.showPassword : context.l10n.hidePassword,
      icon: Icon(
        _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscured = !_obscured),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      enableSuggestions: !widget.isPassword,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.isPassword ? null : widget.minLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: appInputDecoration(
        label: widget.label,
        hint: widget.hint,
        helper: widget.helper,
        prefixText: widget.prefixText,
        suffixIcon: widget.isPassword ? passwordToggle : widget.suffixIcon,
      ),
    );
  }
}
