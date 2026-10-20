import 'package:flutter_test/flutter_test.dart';
import 'package:upcconect/features/feed/domain/usecases/create_post.dart';

void main() {
  group('CreatePost.cleanTags', () {
    test('quita espacios, # y vacías', () {
      expect(CreatePost.cleanTags([' Comida ', '#Postres', '  ', '']), [
        'Comida',
        'Postres',
      ]);
    });

    test('no repite etiquetas aunque cambien las mayúsculas', () {
      expect(CreatePost.cleanTags(['Tecnología', 'tecnología', 'TECNOLOGÍA']), [
        'Tecnología',
      ]);
    });

    test('deja máximo 5 etiquetas', () {
      final tags = CreatePost.cleanTags(['a1', 'a2', 'a3', 'a4', 'a5', 'a6']);
      expect(tags, hasLength(5));
    });

    test('corta las etiquetas de más de 30 letras', () {
      final tags = CreatePost.cleanTags(['x' * 40]);
      expect(tags.single.length, 30);
    });
  });
}
