import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/date_text_input_formatter.dart';
import '../utils/date_utils.dart';
import 'app_text_field.dart';

/// Campo de fecha que se puede llenar de dos formas:
/// escribiendo dd/mm/aaaa (las barras se ponen solas) o tocando el
/// ícono del calendario.
class DateInputField extends StatelessWidget {
  const DateInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.calendarTooltip,
    required this.firstDate,
    required this.lastDate,
    this.initialCalendarDate,
    this.validator,
    this.textInputAction,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String calendarTooltip;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Fecha que muestra el calendario si el campo está vacío.
  final DateTime? initialCalendarDate;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;

  Future<void> _openCalendar(BuildContext context) async {
    final typed = parseDayMonthYear(controller.text);
    var initial = typed ?? initialCalendarDate ?? lastDate;
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) controller.text = formatDayMonthYear(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.birthday],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        const DateTextInputFormatter(),
      ],
      validator: validator,
      enabled: enabled,
      suffixIcon: IconButton(
        tooltip: calendarTooltip,
        icon: const Icon(Icons.calendar_month_outlined),
        onPressed: enabled ? () => _openCalendar(context) : null,
      ),
    );
  }
}
