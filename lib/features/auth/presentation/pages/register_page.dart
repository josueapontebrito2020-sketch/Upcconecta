import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/lower_case_text_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/date_input_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../academic/presentation/widgets/faculty_program_fields.dart';
import '../../../profile/domain/entities/profile_photo.dart';
import '../../../profile/presentation/widgets/avatar_picker.dart';
import '../../domain/entities/sign_up_data.dart';
import '../auth_failure_message.dart';
import '../auth_validators.dart';
import '../controllers/register_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_card.dart';
import '../widgets/data_consent_field.dart';

/// Pantalla "Crea tu cuenta". Al enviarla, Supabase manda un código al
/// correo y la app pasa a "Verifica tu correo".
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  ProfilePhoto? _photo;
  int? _facultyId;
  int? _programId;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // En la web no se quita el foco: en el navegador eso puede dejar los
    // campos sin poder escribir. En el celular sí, para cerrar el teclado.
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();
    final data = SignUpData(
      fullName: _fullNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      // Los validadores ya comprobaron la fecha, la facultad y la carrera.
      birthDate: parseDayMonthYear(_birthDateController.text.trim())!,
      facultyId: _facultyId!,
      programId: _programId!,
      phone: phone.isEmpty ? null : phone,
      bio: _bioController.text,
    );

    final sent = await ref
        .read(registerControllerProvider.notifier)
        .submit(data: data, photo: _photo);
    if (sent && mounted) context.go(AppRoutes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = AuthValidators(l10n);
    final state = ref.watch(registerControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.authFailure;

    final today = DateTime.now();
    final oldestBirthDate = DateTime(
      today.year - AppConstants.maxAge,
      today.month,
      today.day,
    );
    final youngestBirthDate = DateTime(
      today.year - AppConstants.minAge,
      today.month,
      today.day,
    );

    return AuthCard(
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle(AppConstants.institutionalDomain),
      onBack: isLoading ? null : () => context.go(AppRoutes.login),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AvatarPicker(
                photo: _photo,
                onChanged: (photo) => setState(() => _photo = photo),
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _fullNameController,
                label: l10n.fullNameLabel,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: validators.fullName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _usernameController,
                label: l10n.usernameLabel,
                helper: l10n.usernameHelper,
                prefixText: '@',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                inputFormatters: [
                  const LowerCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9_.]')),
                  LengthLimitingTextInputFormatter(
                    AppConstants.usernameMaxLength,
                  ),
                ],
                validator: validators.username,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: l10n.emailLabel,
                hint: l10n.emailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: validators.institutionalEmail,
              ),
              const SizedBox(height: 16),
              DateInputField(
                controller: _birthDateController,
                label: l10n.birthDateLabel,
                hint: l10n.birthDateHint,
                calendarTooltip: l10n.birthDateCalendarTooltip,
                firstDate: oldestBirthDate,
                lastDate: youngestBirthDate,
                initialCalendarDate: DateTime(today.year - 18),
                textInputAction: TextInputAction.next,
                validator: validators.birthDate,
              ),
              const SizedBox(height: 16),
              FacultyProgramFields(
                facultyId: _facultyId,
                programId: _programId,
                onFacultyChanged: (id) => setState(() => _facultyId = id),
                onProgramChanged: (id) => setState(() => _programId = id),
                facultyValidator: validators.faculty,
                programValidator: validators.program,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: l10n.phoneLabel,
                hint: l10n.phoneHint,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: validators.optionalPhone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _bioController,
                label: l10n.bioLabel,
                hint: l10n.bioHint,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                maxLength: AppConstants.maxBioLength,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _passwordController,
                label: l10n.passwordLabel,
                helper: l10n.newPasswordHelper(AppConstants.minPasswordLength),
                isPassword: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: validators.newPassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmController,
                label: l10n.confirmPasswordLabel,
                isPassword: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: validators.confirmPassword(
                  () => _passwordController.text,
                ),
              ),
              const SizedBox(height: 12),
              DataConsentField(enabled: !isLoading),
              const SizedBox(height: 16),
              if (failure != null) ...[
                AuthErrorBanner(message: failure.message(l10n)),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: l10n.createAccountButton,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              AuthFooterLink(
                question: l10n.haveAccountQuestion,
                action: l10n.signInButton,
                onPressed: isLoading ? null : () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
