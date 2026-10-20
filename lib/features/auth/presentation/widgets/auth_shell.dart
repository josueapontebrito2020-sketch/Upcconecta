import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_background.dart';

/// Marco común de todas las pantallas de acceso (login, registro,
/// verificación y recuperar contraseña).
///
/// El fondo vive aquí y no en cada pantalla: así, al pasar de una pantalla a
/// otra, el fondo se queda quieto y solo cambia la tarjeta del centro.
/// La primera vez, la foto del campus hace un acercamiento suave.
class AuthShell extends StatefulWidget {
  const AuthShell({super.key, required this.child});

  /// La pantalla actual (la tarjeta del centro).
  final Widget child;

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final Animation<double> _backgroundScale = _zoom.drive(
    Tween<double>(begin: 1.15, end: 1).chain(
      CurveTween(curve: Curves.easeOutCubic),
    ),
  );
  bool _started = false;

  /// Arranca cuando la foto ya se ve, para que el acercamiento se note.
  void _startZoom() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Con las animaciones del sistema desactivadas, el fondo queda quieto.
      if (MediaQuery.disableAnimationsOf(context)) {
        _zoom.value = 1;
      } else {
        _zoom.forward();
      }
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.verdeProfundo,
        body: Stack(
          children: [
            Positioned.fill(
              child: AuthBackground(
                scale: _backgroundScale,
                onImageShown: _startZoom,
              ),
            ),
            Positioned.fill(child: widget.child),
          ],
        ),
      ),
    );
  }
}
