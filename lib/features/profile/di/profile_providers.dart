import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/di/supabase_providers.dart';
import '../data/repositories/fake_profile_repository.dart';
import '../data/repositories/supabase_profile_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/check_username_available.dart';
import '../domain/usecases/get_follow_list.dart';
import '../domain/usecases/get_profile.dart';
import '../domain/usecases/get_profile_viewers.dart';
import '../domain/usecases/register_profile_view.dart';
import '../domain/usecases/search_users.dart';
import '../domain/usecases/update_profile.dart';
import '../domain/usecases/upload_avatar.dart';

// Inyección de dependencias del módulo de perfil.

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (AppEnv.hasSupabase) {
    return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
  }
  return FakeProfileRepository();
});

final uploadAvatarProvider = Provider<UploadAvatar>((ref) {
  return UploadAvatar(ref.watch(profileRepositoryProvider));
});

final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
});

final checkUsernameAvailableProvider = Provider<CheckUsernameAvailable>((ref) {
  return CheckUsernameAvailable(ref.watch(profileRepositoryProvider));
});

final searchUsersUseCaseProvider = Provider<SearchUsers>((ref) {
  return SearchUsers(ref.watch(profileRepositoryProvider));
});

final getFollowListProvider = Provider<GetFollowList>((ref) {
  return GetFollowList(ref.watch(profileRepositoryProvider));
});

final registerProfileViewProvider = Provider<RegisterProfileView>((ref) {
  return RegisterProfileView(ref.watch(profileRepositoryProvider));
});

final getProfileViewersProvider = Provider<GetProfileViewers>((ref) {
  return GetProfileViewers(ref.watch(profileRepositoryProvider));
});
