import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../auth_failure_message.dart';
import '../auth_validators.dart';
import '../controllers/reset_password_controller.dart';
import '../providers/password_reset_email_provider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_card.dart';

/// Pantalla "Crea una contraseña nueva": código del correo + contraseña
/// nueva. Si todo sale bien, la sesión se inicia y el router lleva al inicio.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // En la web no se quita el foco: en el navegador eso puede dejar los
    // campos sin poder escribir. En el celular sí, para cerrar el teclado.
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(resetPasswordControllerProvider.notifier)
        .reset(
          code: _codeController.text,
          newPassword: _passwordController.text,
        );
  }

  Future<void> _resend() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final sent = await ref
        .read(resetPasswordControllerProvider.notifier)
        .resend();
    if (sent) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.codeResent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(passwordResetEmailProvider);

    // Se llegó aquí sin pedir el código (por ejemplo, al recargar la página).
    if (email == null) {
      return AuthCard(
        title: l10n.resetTitle,
        subtitle: l10n.resetNoPending,
        onBack: () => context.go(AppRoutes.login),
        child: PrimaryButton(
          label: l10n.sendCodeButton,
          onPressed: () => context.go(AppRoutes.forgotPassword),
        ),
      );
    }

    final validators = AuthValidators(l10n);
    final state = ref.watch(resetPasswordControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.authFailure;

    return AuthCard(
      title: l10n.resetTitle,
      subtitle: l10n.resetSubtitle(email),
      onBack: isLoading ? null : () => context.go(AppRoutes.forgotPassword),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _codeController,
                label: l10n.codeLabel,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(AppConstants.otpMaxLength),
                ],
                validator: validators.verificationCode,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.checkSpam,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: l10n.newPasswordLabel,
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
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              if (failure != null) ...[
                AuthErrorBanner(message: failure.message(l10n)),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: l10n.resetButton,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : _resend,
                child: Text(l10n.resendCodeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
