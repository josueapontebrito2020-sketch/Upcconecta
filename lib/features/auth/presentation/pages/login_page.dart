import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../auth_failure_message.dart';
import '../auth_validators.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_footer_link.dart';

/// La animación de entrada solo se muestra la primera vez que se abre el
/// login; al volver desde otra pantalla basta la transición normal.
bool _introAlreadyPlayed = false;

/// Pantalla de inicio de sesión. Al abrir la app:
///
/// 1. La tarjeta aparece subiendo suavemente.
/// 2. El logo entra con un pequeño rebote.
///
/// (El acercamiento de la foto del fondo lo hace `AuthShell`.)
/// La animación empieza cuando el logo ya cargó, para que se vea completa.
/// Si el sistema tiene las animaciones desactivadas, solo hay un fundido.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  bool _introStarted = false;
  bool _reduceMotion = false;

  Animation<double> _interval(double begin, double end, Curve curve) {
    return _intro.drive(CurveTween(curve: Interval(begin, end, curve: curve)));
  }

  late final Animation<double> _cardFade = _interval(0, 0.5, Curves.easeOut);
  late final Animation<Offset> _cardSlide = _interval(
    0,
    0.6,
    Curves.easeOutCubic,
  ).drive(Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero));
  late final Animation<double> _logoScale = _interval(
    0.3,
    0.85,
    Curves.easeOutBack,
  ).drive(Tween<double>(begin: 0.4, end: 1));

  @override
  void initState() {
    super.initState();
    if (_introAlreadyPlayed) {
      _introStarted = true;
      _intro.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  /// Se llama cuando el logo ya se ve en pantalla.
  void _startIntro() {
    if (_introStarted) return;
    _introStarted = true;
    _introAlreadyPlayed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_reduceMotion) _intro.duration = const Duration(milliseconds: 400);
      _intro.forward();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // En la web no se quita el foco: en el navegador eso puede dejar los
    // campos sin poder escribir. En el celular sí, para cerrar el teclado.
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(loginControllerProvider.notifier).submit(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = AuthValidators(l10n);
    final state = ref.watch(loginControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.authFailure;

    final logo = Image.asset(
      AppAssets.logo,
      height: 120,
      semanticLabel: l10n.logoLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame != null || wasSynchronouslyLoaded) _startIntro();
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        _startIntro();
        return const SizedBox(height: 120);
      },
    );

    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        // Sin animaciones del sistema: solo fundido, sin movimiento.
        position: _reduceMotion ? _noOffset : _cardSlide,
        child: AuthCard(
          logo: _reduceMotion
              ? logo
              : ScaleTransition(scale: _logoScale, child: logo),
          title: l10n.loginTitle,
          subtitle: l10n.loginSubtitle,
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  AppTextField(
                    controller: _passwordController,
                    label: l10n.passwordLabel,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: validators.loginPassword,
                    onSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(AppRoutes.forgotPassword),
                      child: Text(l10n.forgotPasswordLink),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (failure != null) ...[
                    AuthErrorBanner(message: failure.message(l10n)),
                    const SizedBox(height: 16),
                  ],
                  PrimaryButton(
                    label: l10n.signInButton,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  AuthFooterLink(
                    question: l10n.noAccountQuestion,
                    action: l10n.createAccountLink,
                    onPressed: isLoading
                        ? null
                        : () => context.go(AppRoutes.register),
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

/// Posición final fija (sin desplazamiento), para cuando no hay animación.
const Animation<Offset> _noOffset = AlwaysStoppedAnimation<Offset>(
  Offset.zero,
);
