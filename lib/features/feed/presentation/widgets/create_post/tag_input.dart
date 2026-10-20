import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_input_decoration.dart';
import '../../../domain/usecases/create_post.dart';

/// Etiquetas libres (hasta 5): se escriben y se agregan con Enter o coma.
/// Debajo se sugieren algunas comunes.
class TagInput extends StatefulWidget {
  const TagInput({super.key, required this.tags, required this.onChanged});

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  /// Sugerencias rápidas.
  static const List<String> suggestions = [
    'Tecnología',
    'Comida',
    'Tutorías',
    'Programación',
    'Diseño',
    'Música',
    'Deportes',
    'Ropa',
    'Libros',
    'Arte',
  ];

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();

  bool get _isFull => widget.tags.length >= AppConstants.postMaxTags;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String text) {
    final tags = CreatePost.cleanTags([...widget.tags, ...text.split(',')]);
    _controller.clear();
    if (tags.length != widget.tags.length) widget.onChanged(tags);
  }

  void _remove(String tag) {
    widget.onChanged([...widget.tags]..remove(tag));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lowerTags = {for (final tag in widget.tags) tag.toLowerCase()};
    final suggestions = [
      for (final tag in TagInput.suggestions)
        if (!lowerTags.contains(tag.toLowerCase())) tag,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in widget.tags)
                InputChip(
                  label: Text(tag),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.verdeUpc,
                  ),
                  backgroundColor: AppColors.verdeUpc.withValues(alpha: 0.08),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  deleteIconColor: AppColors.verdeUpc,
                  deleteButtonTooltipMessage: l10n.createPostRemoveTag,
                  onDeleted: () => _remove(tag),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _controller,
          // readOnly (no enabled: false): en la web, desactivar un campo puede
          // dejarlo sin poder escribir después.
          readOnly: _isFull,
          maxLength: AppConstants.postMaxTagLength,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: appInputDecoration(
            label: _isFull ? l10n.createPostTagsFull : l10n.createPostTagLabel,
            hint: l10n.createPostTagHint,
            suffixIcon: IconButton(
              tooltip: l10n.createPostAddTag,
              onPressed: _isFull ? null : () => _add(_controller.text),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ).copyWith(counterText: ''),
          onChanged: (text) {
            if (text.contains(',')) _add(text);
          },
          onSubmitted: _add,
        ),
        if (!_isFull && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in suggestions)
                ActionChip(
                  label: Text(tag),
                  avatar: const Icon(Icons.add, size: 16),
                  labelStyle: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.tintaSuave,
                  ),
                  side: const BorderSide(color: AppColors.borde),
                  shape: const StadiumBorder(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _add(tag),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
