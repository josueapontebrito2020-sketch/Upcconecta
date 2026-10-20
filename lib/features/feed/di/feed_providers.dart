import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/di/supabase_providers.dart';
import '../data/repositories/fake_feed_repository.dart';
import '../data/repositories/supabase_feed_repository.dart';
import '../domain/repositories/feed_repository.dart';
import '../domain/usecases/create_post.dart';
import '../domain/usecases/delete_post.dart';
import '../domain/usecases/get_feed_posts.dart';
import '../domain/usecases/get_profile_posts.dart';
import '../domain/usecases/hide_post.dart';
import '../domain/usecases/register_share.dart';
import '../domain/usecases/report_post.dart';
import '../domain/usecases/toggle_follow.dart';
import '../domain/usecases/toggle_like.dart';
import '../domain/usecases/toggle_save.dart';

// Inyección de dependencias del inicio (feed).

/// Con Supabase usa las tablas de la migración `20261020130000_publicaciones`;
/// sin claves, publicaciones de prueba en memoria.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  if (AppEnv.hasSupabase) {
    return SupabaseFeedRepository(ref.watch(supabaseClientProvider));
  }
  return FakeFeedRepository();
});

final getFeedPostsProvider = Provider<GetFeedPosts>((ref) {
  return GetFeedPosts(ref.watch(feedRepositoryProvider));
});

final getProfilePostsProvider = Provider<GetProfilePosts>((ref) {
  return GetProfilePosts(ref.watch(feedRepositoryProvider));
});

final toggleLikeProvider = Provider<ToggleLike>((ref) {
  return ToggleLike(ref.watch(feedRepositoryProvider));
});

final toggleSaveProvider = Provider<ToggleSave>((ref) {
  return ToggleSave(ref.watch(feedRepositoryProvider));
});

final toggleFollowProvider = Provider<ToggleFollow>((ref) {
  return ToggleFollow(ref.watch(feedRepositoryProvider));
});

final registerShareProvider = Provider<RegisterShare>((ref) {
  return RegisterShare(ref.watch(feedRepositoryProvider));
});

final createPostProvider = Provider<CreatePost>((ref) {
  return CreatePost(ref.watch(feedRepositoryProvider));
});

final deletePostProvider = Provider<DeletePost>((ref) {
  return DeletePost(ref.watch(feedRepositoryProvider));
});

final hidePostProvider = Provider<HidePost>((ref) {
  return HidePost(ref.watch(feedRepositoryProvider));
});

final reportPostProvider = Provider<ReportPost>((ref) {
  return ReportPost(ref.watch(feedRepositoryProvider));
});
