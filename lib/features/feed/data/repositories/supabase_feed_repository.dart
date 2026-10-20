import 'dart:developer' as developer;
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/feed_section.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/post_list_source.dart';
import '../../domain/entities/report_reason.dart';
import '../../domain/repositories/feed_repository.dart';
import '../models/feed_post_row.dart';

/// Inicio guardado en Supabase (migración `20261020130000_publicaciones.sql`):
/// vista `feed_posts`, tablas de me gusta, guardados, seguidores, ocultas y
/// reportes, y archivos en el bucket `posts`.
class SupabaseFeedRepository implements FeedRepository {
  SupabaseFeedRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'posts';

  /// Publicaciones por carga. (Más adelante: cargar más al llegar al final.)
  static const int _pageSize = 30;

  /// Código de Postgres para "ya existe" (ej. dar me gusta dos veces).
  static const String _uniqueViolation = '23505';

  StorageFileApi get _storage => _client.storage.from(_bucket);

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Result<List<Post>, DataFailure>> getPosts({
    required FeedSection section,
    PostCategory? category,
  }) {
    return _guard('cargar el inicio', () async {
      if (section == FeedSection.transport) return const <Post>[];

      var query = _client.from('feed_posts').select();
      if (section == FeedSection.featured) {
        query = query.eq('is_featured', true);
      }
      if (category != null) {
        query = query.eq('category', categoryToDb(category));
      }
      final rows = await query
          .order('created_at', ascending: false)
          .limit(_pageSize);

      return [for (final row in rows) _toPost(row)];
    });
  }

  @override
  Future<Result<List<Post>, DataFailure>> getProfilePosts({
    required String userId,
    required PostCollection collection,
  }) {
    return _guard('cargar publicaciones del perfil', () async {
      if (collection == PostCollection.authored) {
        final rows = await _client
            .from('feed_posts')
            .select()
            .eq('author_id', userId)
            .order('created_at', ascending: false)
            .limit(_pageSize * 2);
        return [for (final row in rows) _toPost(row)];
      }

      // Guardadas, me gusta y compartidas: primero los ids en el orden en
      // que se hicieron y luego las publicaciones.
      final (table, dateColumn) = switch (collection) {
        PostCollection.saved => ('post_saves', 'created_at'),
        PostCollection.liked => ('post_likes', 'created_at'),
        _ => ('post_shares', 'shared_at'),
      };
      final idRows = await _client
          .from(table)
          .select('post_id')
          .eq('user_id', userId)
          .order(dateColumn, ascending: false)
          .limit(_pageSize * 2);
      final ids = [for (final row in idRows) row['post_id'] as String];
      if (ids.isEmpty) return const <Post>[];

      final rows = await _client.from('feed_posts').select().inFilter('id', ids);
      final byId = {for (final row in rows) row['id'] as String: _toPost(row)};
      return [
        for (final id in ids)
          if (byId[id] case final post?) post,
      ];
    });
  }

  Post _toPost(Map<String, dynamic> row) {
    return postFromFeedRow(row, publicUrl: _storage.getPublicUrl);
  }

  @override
  Future<Result<String, DataFailure>> createPost(NewPost post) async {
    final userId = _userId;
    if (userId == null) return const Err(DataFailure.unknown);

    // Carpeta única para los archivos de esta publicación.
    final folder =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 30)}';
    final uploaded = <String>[];

    try {
      for (var i = 0; i < post.media.length; i++) {
        final file = post.media[i];
        final path = '$userId/$folder/$i.${file.extension}';
        await _storage.uploadBinary(
          path,
          file.bytes,
          fileOptions: FileOptions(contentType: file.contentType),
        );
        uploaded.add(path);
      }

      final postId = await _client.rpc<dynamic>(
        'create_post',
        params: {
          'p_content': post.text,
          'p_category': categoryToDb(post.category),
          'p_tags': post.tags,
          'p_media': [
            for (var i = 0; i < uploaded.length; i++)
              {
                'path': uploaded[i],
                'type': post.media[i].isVideo ? 'video' : 'image',
              },
          ],
        },
      );
      return Ok(postId as String);
    } catch (error) {
      developer.log('Error al publicar', error: error);
      // Si algo falló, no dejar archivos huérfanos en el bucket.
      if (uploaded.isNotEmpty) {
        try {
          await _storage.remove(uploaded);
        } catch (_) {}
      }
      return Err(_failureFrom(error));
    }
  }

  @override
  Future<Result<void, DataFailure>> deletePost(String postId) {
    return _run('borrar la publicación', () async {
      final rows = await _client
          .from('post_media')
          .select('storage_path')
          .eq('post_id', postId);
      final paths = [for (final row in rows) row['storage_path'] as String];

      await _client.from('posts').delete().eq('id', postId);

      // Primero la base de datos; si borrar los archivos falla, la
      // publicación ya no se ve igual.
      if (paths.isNotEmpty) {
        try {
          await _storage.remove(paths);
        } catch (error) {
          developer.log('No se borraron los archivos', error: error);
        }
      }
    });
  }

  @override
  Future<Result<void, DataFailure>> setLiked(
    String postId, {
    required bool liked,
  }) {
    return _run('me gusta', () async {
      if (liked) {
        await _insertIgnoringDuplicate('post_likes', {'post_id': postId});
      } else {
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', _userId ?? '');
      }
    });
  }

  @override
  Future<Result<void, DataFailure>> setSaved(
    String postId, {
    required bool saved,
  }) {
    return _run('guardar', () async {
      if (saved) {
        await _insertIgnoringDuplicate('post_saves', {'post_id': postId});
      } else {
        await _client
            .from('post_saves')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', _userId ?? '');
      }
    });
  }

  @override
  Future<Result<void, DataFailure>> setFollowing(
    String authorId, {
    required bool following,
  }) {
    return _run('seguir', () async {
      if (following) {
        await _insertIgnoringDuplicate('follows', {'followed_id': authorId});
      } else {
        await _client
            .from('follows')
            .delete()
            .eq('follower_id', _userId ?? '')
            .eq('followed_id', authorId);
      }
    });
  }

  @override
  Future<Result<void, DataFailure>> registerShare(String postId) {
    return _run('compartir', () async {
      await _client.rpc<dynamic>(
        'register_post_share',
        params: {'p_post_id': postId},
      );
    });
  }

  @override
  Future<Result<void, DataFailure>> hidePost(String postId) {
    return _run('ocultar', () async {
      await _insertIgnoringDuplicate('hidden_posts', {'post_id': postId});
    });
  }

  @override
  Future<Result<void, DataFailure>> reportPost(
    String postId,
    ReportReason reason,
  ) {
    return _run('reportar', () async {
      // Reportar dos veces la misma publicación cuenta como hecho.
      await _insertIgnoringDuplicate('post_reports', {
        'post_id': postId,
        'reason': reason.name,
      });
    });
  }

  Future<void> _insertIgnoringDuplicate(
    String table,
    Map<String, Object> values,
  ) async {
    try {
      await _client.from(table).insert(values);
    } on PostgrestException catch (error) {
      if (error.code != _uniqueViolation) rethrow;
    }
  }

  /// Ejecuta una operación sin resultado y convierte los errores en
  /// [DataFailure].
  Future<Result<void, DataFailure>> _run(
    String action,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Ok(null);
    } catch (error) {
      developer.log('Error al $action', error: error);
      return Err(_failureFrom(error));
    }
  }

  /// Ejecuta una operación y convierte cualquier error en [DataFailure].
  Future<Result<T, DataFailure>> _guard<T>(
    String action,
    Future<T> Function() operation,
  ) async {
    try {
      return Ok(await operation());
    } catch (error) {
      developer.log('Error al $action', error: error);
      return Err(_failureFrom(error));
    }
  }

  /// Errores que responde Supabase (permisos, datos inválidos…) son
  /// "desconocidos"; los demás (sin respuesta) se tratan como falta de red.
  DataFailure _failureFrom(Object error) {
    return switch (error) {
      PostgrestException() || StorageException() => DataFailure.unknown,
      AuthException() => DataFailure.unknown,
      _ => DataFailure.network,
    };
  }
}
