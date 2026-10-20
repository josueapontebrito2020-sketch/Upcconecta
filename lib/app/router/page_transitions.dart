import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transición entre pantallas: la nueva aparece con un fundido, subiendo y
/// creciendo un poco; la anterior se desvanece al mismo tiempo.
///
/// Con las animaciones del sistema desactivadas, solo hay fundido.
CustomTransitionPage<void> fadeThroughPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final entering = animation.drive(CurveTween(curve: Curves.easeOutCubic));
      final leaving = secondaryAnimation.drive(
        Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
      );

      if (MediaQuery.disableAnimationsOf(context)) {
        return FadeTransition(
          opacity: leaving,
          child: FadeTransition(opacity: entering, child: child),
        );
      }

      return FadeTransition(
        opacity: leaving,
        child: FadeTransition(
          opacity: entering,
          child: SlideTransition(
            position: entering.drive(
              Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero),
            ),
            child: ScaleTransition(
              scale: entering.drive(Tween<double>(begin: 0.96, end: 1)),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
