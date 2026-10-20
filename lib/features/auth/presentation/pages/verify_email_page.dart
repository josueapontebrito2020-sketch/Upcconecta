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
import '../controllers/verify_email_controller.dart';
import '../providers/pending_sign_up_provider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_card.dart';

/// Pantalla "Verifica tu correo": el usuario escribe el código que le llegó.
/// Si es correcto, se inicia la sesión y el router lo lleva al inicio.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    // En la web no se quita el foco: en el navegador eso puede dejar los
    // campos sin poder escribir. En el celular sí, para cerrar el teclado.
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(verifyEmailControllerProvider.notifier)
        .verify(_codeController.text);
  }

  Future<void> _resend() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final sent = await ref.read(verifyEmailControllerProvider.notifier).resend();
    if (sent) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.codeResent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingSignUpProvider);

    // Se llegó aquí sin haber llenado el registro (por ejemplo, al recargar
    // la página en el navegador).
    if (pending == null) {
      return AuthCard(
        title: l10n.verifyTitle,
        subtitle: l10n.verifyNoPending,
        onBack: () => context.go(AppRoutes.login),
        child: PrimaryButton(
          label: l10n.createAccountLink,
          onPressed: () => context.go(AppRoutes.register),
        ),
      );
    }

    final validators = AuthValidators(l10n);
    final state = ref.watch(verifyEmailControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.authFailure;

    return AuthCard(
      title: l10n.verifyTitle,
      subtitle: l10n.verifySubtitle(pending.email),
      onBack: isLoading ? null : () => context.go(AppRoutes.register),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _codeController,
              label: l10n.codeLabel,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AppConstants.otpMaxLength),
              ],
              validator: validators.verificationCode,
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 8),
            Text(l10n.checkSpam, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (failure != null) ...[
              AuthErrorBanner(message: failure.message(l10n)),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              label: l10n.verifyButton,
              isLoading: isLoading,
              onPressed: _verify,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : _resend,
              child: Text(l10n.resendCodeButton),
            ),
          ],
        ),
      ),
    );
  }
}
