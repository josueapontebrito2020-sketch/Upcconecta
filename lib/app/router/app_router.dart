import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../features/auth/di/auth_providers.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/auth/presentation/widgets/auth_shell.dart';
import '../../features/chat/presentation/pages/messages_page.dart';
import '../../features/feed/presentation/pages/create_post_page.dart';
import '../../features/feed/domain/entities/post_list_source.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/post_list_page.dart';
import '../../features/feed/presentation/pages/video_viewer_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/profile/domain/entities/follow_list_type.dart';
import '../../features/profile/presentation/pages/edit_profile_field_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/follow_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_viewers_page.dart';
import '../../features/profile/presentation/pages/search_users_page.dart';
import '../shell/main_shell.dart';
import 'page_transitions.dart';

/// Router de la app. Decide a dónde va el usuario según su sesión:
/// sin sesión, solo las rutas públicas (login, registro, verificación y
/// recuperar contraseña);
/// con sesión, el resto.
///
/// Vive en `app/` y no en `core/` porque conoce las pantallas de los módulos;
/// `core/` no depende de ningún módulo.
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authChanges = _StreamListenable(authRepository.authStateChanges());

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isSignedIn = user != null && user.emailVerified;
      final isPublic = AppRoutes.publicRoutes.contains(state.matchedLocation);

      if (!isSignedIn) return isPublic ? null : AppRoutes.login;
      if (isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      // Con sesión: pestañas de la barra inferior. Cada rama guarda su
      // propio estado al cambiar de pestaña.
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => fadeThroughPage(
          state,
          MainShell(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const FeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.groups,
                builder: (context, state) => const GroupsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (context, state) => const MessagesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createPost,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const CreatePostPage()),
      ),
      // Perfil: se abren encima de las pestañas.
      GoRoute(
        path: AppRoutes.userProfile,
        pageBuilder: (context, state) => fadeThroughPage(
          state,
          ProfilePage(userId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: AppRoutes.followList,
        pageBuilder: (context, state) => fadeThroughPage(
          state,
          FollowListPage(
            userId: state.pathParameters['id'] ?? '',
            initialType: state.uri.queryParameters['ver'] == 'seguidos'
                ? FollowListType.following
                : FollowListType.followers,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.postList,
        pageBuilder: (context, state) {
          final query = state.uri.queryParameters;
          final collection = PostCollection.values.firstWhere(
            (value) => value.name == query['tipo'],
            orElse: () => PostCollection.authored,
          );
          return fadeThroughPage(
            state,
            PostListPage(
              source: ProfilePostsSource(
                userId: query['usuario'] ?? '',
                collection: collection,
              ),
              initialPostId: query['inicio'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const EditProfilePage()),
      ),
      GoRoute(
        path: AppRoutes.editProfileField,
        pageBuilder: (context, state) => fadeThroughPage(
          state,
          EditProfileFieldPage(
            field:
                ProfileField.fromPath(state.pathParameters['campo']) ??
                ProfileField.fullName,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.searchUsers,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const SearchUsersPage()),
      ),
      GoRoute(
        path: AppRoutes.profileViewers,
        pageBuilder: (context, state) =>
            fadeThroughPage(state, const ProfileViewersPage()),
      ),
      GoRoute(
        path: AppRoutes.videoViewer,
        pageBuilder: (context, state) => fadeThroughPage(
          state,
          VideoViewerPage(url: state.uri.queryParameters['url'] ?? ''),
        ),
      ),
      // Pantallas de acceso: comparten el fondo verde (AuthShell), que se
      // queda quieto mientras las tarjetas cambian con una transición.
      ShellRoute(
        pageBuilder: (context, state, child) =>
            fadeThroughPage(state, AuthShell(child: child)),
        routes: [
          GoRoute(
            path: AppRoutes.login,
            pageBuilder: (context, state) =>
                fadeThroughPage(state, const LoginPage()),
          ),
          GoRoute(
            path: AppRoutes.register,
            pageBuilder: (context, state) =>
                fadeThroughPage(state, const RegisterPage()),
          ),
          GoRoute(
            path: AppRoutes.verifyEmail,
            pageBuilder: (context, state) =>
                fadeThroughPage(state, const VerifyEmailPage()),
          ),
          GoRoute(
            path: AppRoutes.forgotPassword,
            pageBuilder: (context, state) =>
                fadeThroughPage(state, const ForgotPasswordPage()),
          ),
          GoRoute(
            path: AppRoutes.resetPassword,
            pageBuilder: (context, state) =>
                fadeThroughPage(state, const ResetPasswordPage()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    authChanges.dispose();
    router.dispose();
  });
  return router;
});

/// Avisa al router cada vez que cambia la sesión para que vuelva a evaluar
/// `redirect`.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (Object error) => debugPrint('Error de sesión: $error'),
    );
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
