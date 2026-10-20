import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../auth_failure_message.dart';
import '../auth_validators.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_card.dart';

/// Pantalla "Recupera tu contraseña": pide el correo institucional y envía
/// un código para crear una contraseña nueva.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // En la web no se quita el foco: en el navegador eso puede dejar los
    // campos sin poder escribir. En el celular sí, para cerrar el teclado.
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final sent = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .sendCode(_emailController.text);
    if (sent && mounted) context.go(AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = AuthValidators(l10n);
    final state = ref.watch(forgotPasswordControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.authFailure;

    return AuthCard(
      title: l10n.forgotTitle,
      subtitle: l10n.forgotSubtitle,
      onBack: isLoading ? null : () => context.go(AppRoutes.login),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              hint: l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: validators.institutionalEmail,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            if (failure != null) ...[
              AuthErrorBanner(message: failure.message(l10n)),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              label: l10n.sendCodeButton,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
