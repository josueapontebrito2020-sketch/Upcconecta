import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estilo común de todos los campos del formulario (texto, listas, fecha),
/// para que se vean iguales.
InputDecoration appInputDecoration({
  required String label,
  String? hint,
  String? helper,
  String? prefixText,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    helperMaxLines: 3,
    errorMaxLines: 3,
    prefixText: prefixText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.campo,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.borde),
    enabledBorder: border(AppColors.borde),
    disabledBorder: border(AppColors.borde),
    focusedBorder: border(AppColors.verdeUpc, width: 2),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error, width: 2),
  );
}
