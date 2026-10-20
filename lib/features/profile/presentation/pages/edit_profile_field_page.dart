import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/lower_case_text_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_input_field.dart';
import '../../../academic/presentation/widgets/faculty_program_fields.dart';
import '../../../auth/presentation/auth_validators.dart';
import '../../di/profile_providers.dart';
import '../../domain/entities/profile_changes.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';
import '../providers/profile_providers.dart';

/// Dato del perfil que se edita en su propia pantalla. [path] es el final
/// de la ruta: `/editar-perfil/<path>`.
enum ProfileField {
  fullName('nombre'),
  username('usuario'),
  bio('descripcion'),
  phone('celular'),
  studies('carrera'),
  birthDate('nacimiento');

  const ProfileField(this.path);

  final String path;

  static ProfileField? fromPath(String? path) {
    for (final field in values) {
      if (field.path == path) return field;
    }
    return null;
  }
}

/// Estado de la revisión del nombre de usuario mientras se escribe.
enum _UsernameStatus { unchanged, checking, available, taken }

/// Pantalla para editar un dato del perfil, con "Guardar" arriba.
class EditProfileFieldPage extends ConsumerStatefulWidget {
  const EditProfileFieldPage({super.key, required this.field});

  final ProfileField field;

  @override
  ConsumerState<EditProfileFieldPage> createState() =>
      _EditProfileFieldPageState();
}

class _EditProfileFieldPageState extends ConsumerState<EditProfileFieldPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String _initialUsername = '';
  int? _facultyId;
  int? _programId;
  Timer? _debounce;
  _UsernameStatus _usernameStatus = _UsernameStatus.unchanged;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserIdProvider);
    final profile = userId == null
        ? null
        : ref.read(profileControllerProvider(userId)).value;
    if (profile == null) return;

    _initialUsername = profile.username;
    _facultyId = profile.facultyId;
    _programId = profile.programId;
    _controller.text = switch (widget.field) {
      ProfileField.fullName => profile.fullName,
      ProfileField.username => profile.username,
      ProfileField.bio => profile.bio,
      ProfileField.phone => profile.phone ?? '',
      ProfileField.studies => '',
      ProfileField.birthDate => switch (profile.birthDate) {
        final date? => formatDayMonthYear(date),
        null => '',
      },
    };
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Revisa si el nombre de usuario está libre, medio segundo después de
  /// dejar de escribir.
  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final username = value.trim().toLowerCase();
    if (username == _initialUsername || username.length < 3) {
      setState(() => _usernameStatus = _UsernameStatus.unchanged);
      return;
    }
    setState(() => _usernameStatus = _UsernameStatus.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final result = await ref
          .read(checkUsernameAvailableProvider)
          .call(username);
      if (!mounted || _controller.text.trim().toLowerCase() != username) {
        return;
      }
      setState(() {
        _usernameStatus = switch (result) {
          Ok(value: true) => _UsernameStatus.available,
          Ok() => _UsernameStatus.taken,
          // Si no se pudo revisar, la base de datos igual lo valida al
          // guardar.
          Err() => _UsernameStatus.unchanged,
        };
      });
    });
  }

  ProfileChanges _changes() {
    final text = _controller.text;
    return switch (widget.field) {
      ProfileField.fullName => ProfileChanges(fullName: text),
      ProfileField.username => ProfileChanges(username: text),
      ProfileField.bio => ProfileChanges(bio: text),
      ProfileField.phone => ProfileChanges(phone: text),
      ProfileField.studies => ProfileChanges(
        facultyId: _facultyId,
        programId: _programId,
      ),
      ProfileField.birthDate => ProfileChanges(
        birthDate: parseDayMonthYear(text),
      ),
    };
  }

  Future<void> _save() async {
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final saved = await ref
        .read(editProfileControllerProvider.notifier)
        .save(_changes());
    if (!mounted) return;

    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      Navigator.of(context).pop();
      return;
    }
    final error = ref.read(editProfileControllerProvider).error;
    if (error == DataFailure.conflict) {
      setState(() => _usernameStatus = _UsernameStatus.taken);
    }
    context.showSnackBar(
      error == DataFailure.conflict
          ? l10n.errorUsernameTaken
          : (error is DataFailure ? error.message(l10n) : l10n.errorUnknown),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = AuthValidators(l10n);
    final saving = ref.watch(editProfileControllerProvider).isLoading;
    final today = DateTime.now();

    final title = switch (widget.field) {
      ProfileField.fullName => l10n.fullNameLabel,
      ProfileField.username => l10n.usernameLabel,
      ProfileField.bio => l10n.editProfileBio,
      ProfileField.phone => l10n.editProfilePhone,
      ProfileField.studies => l10n.editProfileStudies,
      ProfileField.birthDate => l10n.birthDateLabel,
    };

    final Widget input = switch (widget.field) {
      ProfileField.fullName => AppTextField(
        controller: _controller,
        label: l10n.fullNameLabel,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        maxLength: 80,
        validator: validators.fullName,
        onSubmitted: (_) => _save(),
      ),
      ProfileField.username => AppTextField(
        controller: _controller,
        label: l10n.usernameLabel,
        prefixText: '@',
        helper: l10n.usernameHelper,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          const LowerCaseTextFormatter(),
          FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_.]')),
          LengthLimitingTextInputFormatter(AppConstants.usernameMaxLength),
        ],
        suffixIcon: switch (_usernameStatus) {
          _UsernameStatus.unchanged => null,
          _UsernameStatus.checking => const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          _UsernameStatus.available => Tooltip(
            message: l10n.usernameAvailable,
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.verdeUpc,
            ),
          ),
          _UsernameStatus.taken => Tooltip(
            message: l10n.errorUsernameTaken,
            child: const Icon(Icons.cancel_rounded, color: AppColors.error),
          ),
        },
        validator: (value) {
          if (_usernameStatus == _UsernameStatus.taken) {
            return l10n.errorUsernameTaken;
          }
          return validators.username(value);
        },
        onSubmitted: (_) => _save(),
      ),
      ProfileField.bio => AppTextField(
        controller: _controller,
        label: l10n.editProfileBio,
        hint: l10n.bioHint,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        minLines: 4,
        maxLines: 8,
        maxLength: AppConstants.maxBioLength,
      ),
      ProfileField.phone => AppTextField(
        controller: _controller,
        label: l10n.phoneLabel,
        hint: l10n.phoneHint,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: validators.optionalPhone,
        onSubmitted: (_) => _save(),
      ),
      ProfileField.birthDate => DateInputField(
        controller: _controller,
        label: l10n.birthDateLabel,
        hint: l10n.birthDateHint,
        calendarTooltip: l10n.birthDateCalendarTooltip,
        // Misma edad permitida que en el registro.
        firstDate: DateTime(
          today.year - AppConstants.maxAge,
          today.month,
          today.day,
        ),
        lastDate: DateTime(
          today.year - AppConstants.minAge,
          today.month,
          today.day,
        ),
        initialCalendarDate: DateTime(today.year - 18),
        textInputAction: TextInputAction.done,
        validator: validators.birthDate,
      ),
      ProfileField.studies => FacultyProgramFields(
        facultyId: _facultyId,
        programId: _programId,
        onFacultyChanged: (id) => setState(() => _facultyId = id),
        onProgramChanged: (id) => setState(() => _programId = id),
        facultyValidator: validators.faculty,
        programValidator: validators.program,
      ),
    };

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: AppColors.fondo,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed:
                  _usernameStatus == _UsernameStatus.checking ? null : _save,
              child: Text(l10n.saveButton),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Material(
                    color: AppColors.superficie,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: widget.field == ProfileField.username
                          ? _UsernameListener(
                              controller: _controller,
                              onChanged: _onUsernameChanged,
                              child: input,
                            )
                          : input,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avisa cada cambio del texto (AppTextField no tiene `onChanged`).
class _UsernameListener extends StatefulWidget {
  const _UsernameListener({
    required this.controller,
    required this.onChanged,
    required this.child,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Widget child;

  @override
  State<_UsernameListener> createState() => _UsernameListenerState();
}

class _UsernameListenerState extends State<_UsernameListener> {
  late String _last = widget.controller.text;

  void _listener() {
    final text = widget.controller.text;
    if (text == _last) return;
    _last = text;
    widget.onChanged(text);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
