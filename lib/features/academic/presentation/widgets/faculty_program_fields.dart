import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_input_decoration.dart';
import '../../di/academic_providers.dart';
import '../../domain/entities/academic_program.dart';
import '../../domain/entities/faculty.dart';

/// Dos listas encadenadas: primero la facultad y, según la facultad elegida,
/// sus carreras. Al cambiar de facultad, la carrera se borra.
class FacultyProgramFields extends ConsumerWidget {
  const FacultyProgramFields({
    super.key,
    required this.facultyId,
    required this.programId,
    required this.onFacultyChanged,
    required this.onProgramChanged,
    this.facultyValidator,
    this.programValidator,
    this.enabled = true,
  });

  final int? facultyId;
  final int? programId;
  final ValueChanged<int?> onFacultyChanged;
  final ValueChanged<int?> onProgramChanged;
  final FormFieldValidator<int>? facultyValidator;
  final FormFieldValidator<int>? programValidator;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final faculties = ref.watch(facultiesProvider);

    return faculties.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _LoadError(
        message: l10n.academicLoadError,
        onRetry: () => ref.invalidate(facultiesProvider),
      ),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FacultyDropdown(
            faculties: list,
            value: facultyId,
            onChanged: enabled
                ? (id) {
                    onFacultyChanged(id);
                    onProgramChanged(null);
                  }
                : null,
            validator: facultyValidator,
          ),
          const SizedBox(height: 16),
          if (facultyId == null)
            _ProgramDropdown(
              key: const ValueKey('program-empty'),
              programs: const [],
              value: null,
              hint: l10n.programHintNoFaculty,
              onChanged: null,
              validator: programValidator,
            )
          else
            _ProgramsForFaculty(
              key: ValueKey('programs-$facultyId'),
              facultyId: facultyId!,
              value: programId,
              onChanged: enabled ? onProgramChanged : null,
              validator: programValidator,
            ),
        ],
      ),
    );
  }
}

class _FacultyDropdown extends StatelessWidget {
  const _FacultyDropdown({
    required this.faculties,
    required this.value,
    required this.onChanged,
    required this.validator,
  });

  final List<Faculty> faculties;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final FormFieldValidator<int>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      itemHeight: null,
      decoration: appInputDecoration(label: context.l10n.facultyLabel),
      items: [
        for (final faculty in faculties)
          DropdownMenuItem(
            value: faculty.id,
            child: Text(
              faculty.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _ProgramsForFaculty extends ConsumerWidget {
  const _ProgramsForFaculty({
    super.key,
    required this.facultyId,
    required this.value,
    required this.onChanged,
    required this.validator,
  });

  final int facultyId;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final FormFieldValidator<int>? validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final programs = ref.watch(programsProvider(facultyId));

    return programs.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => _LoadError(
        message: l10n.academicLoadError,
        onRetry: () => ref.invalidate(programsProvider(facultyId)),
      ),
      data: (list) => _ProgramDropdown(
        programs: list,
        value: value,
        hint: null,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class _ProgramDropdown extends StatelessWidget {
  const _ProgramDropdown({
    super.key,
    required this.programs,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.validator,
  });

  final List<AcademicProgram> programs;
  final int? value;
  final String? hint;
  final ValueChanged<int?>? onChanged;
  final FormFieldValidator<int>? validator;

  @override
  Widget build(BuildContext context) {
    final hintText = hint;
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      itemHeight: null,
      decoration: appInputDecoration(label: context.l10n.programLabel),
      disabledHint: hintText == null ? null : Text(hintText),
      items: [
        for (final program in programs)
          DropdownMenuItem(
            value: program.id,
            child: Text(
              program.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    );
  }
}
