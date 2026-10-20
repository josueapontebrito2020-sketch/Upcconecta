import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/data_failure.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/di/auth_providers.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import 'widgets/main_bottom_bar.dart';

/// Marco de la app con sesión iniciada: la pestaña actual arriba y la barra
/// inferior (Inicio, Grupos, Publicar, Mensajes, Perfil).
///
/// Cada pestaña guarda su estado (posición de la lista, etc.) al cambiar
/// de una a otra, gracias a `StatefulShellRoute.indexedStack`.
///
/// Al abrir, carga el perfil propio: si la cuenta ya no existe (se borró en
/// Supabase), cierra la sesión.
///
/// Vive en `app/` porque reúne pantallas de varios módulos.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tocar la pestaña en la que ya estás vuelve a su pantalla inicial.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId != null) {
      ref.listen(profileControllerProvider(userId), (previous, next) {
        if (next.error == DataFailure.notFound) {
          ref.read(signOutProvider).call();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: navigationShell,
      bottomNavigationBar: MainBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _onTabSelected,
        onCreateTap: () => context.push(AppRoutes.createPost),
      ),
    );
  }
}
