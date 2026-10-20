import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/di/auth_providers.dart';
import '../../domain/entities/new_post.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_author.dart';
import '../../domain/entities/post_category.dart';
import '../../domain/entities/post_media.dart';
import '../controllers/create_post_controller.dart';
import '../widgets/create_post/category_picker.dart';
import '../widgets/create_post/form_section.dart';
import '../widgets/create_post/media_picker.dart';
import '../widgets/create_post/tag_input.dart';
import '../widgets/post_card.dart';

/// Pantalla "Nueva publicación" (botón + de la barra inferior): categoría,
/// descripción, fotos o video y etiquetas. Con "Vista previa" se ve cómo
/// quedará en el inicio antes de publicar.
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  PostCategory? _category;
  List<String> _tags = const [];
  List<NewPostMedia> _media = const [];
  bool _showCategoryError = false;
  bool _published = false;

  bool get _hasContent =>
      _textController.text.trim().isNotEmpty ||
      _category != null ||
      _tags.isNotEmpty ||
      _media.isNotEmpty;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  NewPost _buildPost() {
    return NewPost(
      text: _textController.text,
      category: _category ?? PostCategory.product,
      tags: _tags,
      media: _media,
    );
  }

  /// Revisa el formulario; si falta algo, lo marca en rojo.
  bool _validate() {
    final textOk = _formKey.currentState?.validate() ?? false;
    setState(() => _showCategoryError = _category == null);
    return textOk && _category != null;
  }

  Future<void> _submit() async {
    // En la web no se quita el foco (puede dejar los campos sin escribir).
    if (!kIsWeb) FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final published = await ref
        .read(createPostControllerProvider.notifier)
        .submit(_buildPost());
    if (!published || !mounted) return;

    messenger.showSnackBar(SnackBar(content: Text(l10n.createPostDone)));
    _leave();
  }

  /// Cierra la pantalla sin volver a preguntar. Se espera un cuadro para
  /// que `PopScope` ya permita salir.
  void _leave() {
    setState(() => _published = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showPreview() {
    if (!_validate()) return;
    final l10n = context.l10n;
    final user = ref.read(currentUserProvider);
    final post = _buildPost();

    final preview = Post(
      id: 'vista-previa',
      author: PostAuthor(
        id: user?.id ?? '',
        username: user?.email.split('@').first ?? '',
        fullName: user?.displayName.trim().isNotEmpty == true
            ? user!.displayName
            : l10n.createPostYou,
      ),
      text: post.text.trim(),
      category: post.category,
      tags: post.tags,
      createdAt: DateTime.now(),
      isMine: true,
      media: [
        for (final file in post.media)
          PostMedia(
            url: '',
            bytes: file.isVideo ? null : file.bytes,
            type: file.isVideo ? PostMediaType.video : PostMediaType.image,
          ),
      ],
    );

    void nothing() {}
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.fondo,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.createPostPreviewTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              PostCard(
                post: preview,
                onAuthorTap: nothing,
                onOptionsTap: nothing,
                onCategoryTap: nothing,
                onVideoTap: nothing,
                onReviewsTap: nothing,
                onRequestTap: nothing,
                onChatTap: nothing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Si hay algo escrito, pregunta antes de salir sin publicar.
  Future<void> _confirmDiscard() async {
    final l10n = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createPostDiscardTitle),
        content: Text(l10n.createPostDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.createPostKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.createPostDiscard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(createPostControllerProvider);
    final isLoading = state.isLoading;
    final failure = state.hasError ? state.error : null;
    final user = ref.watch(currentUserProvider);
    final userName = user == null
        ? ''
        : (user.displayName.trim().isEmpty ? user.firstName : user.displayName);

    return PopScope(
      // Salir siempre pasa por aquí: si hay algo escrito, se pregunta.
      canPop: _published,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isLoading) return;
        if (_hasContent) {
          _confirmDiscard();
        } else {
          _leave();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.fondo,
        appBar: AppBar(
          title: Text(l10n.createPostTitle),
          backgroundColor: AppColors.superficie,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: l10n.closeTooltip,
            icon: const Icon(Icons.close_rounded),
          ),
          actions: [
            TextButton.icon(
              onPressed: isLoading ? null : _showPreview,
              icon: const Icon(Icons.visibility_outlined, size: 20),
              label: Text(l10n.createPostPreview),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Row(
                      children: [
                        UserAvatar(name: userName, size: 44),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.createPostVisibility,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FormSection(
                      title: l10n.createPostCategoryTitle,
                      subtitle: l10n.createPostCategoryHint,
                      errorText: _showCategoryError && _category == null
                          ? l10n.createPostCategoryRequired
                          : null,
                      child: CategoryPicker(
                        selected: _category,
                        onSelected: (category) =>
                            setState(() => _category = category),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormSection(
                      title: l10n.createPostTextTitle,
                      child: AppTextField(
                        controller: _textController,
                        label: l10n.createPostTextLabel,
                        hint: l10n.createPostTextHint,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 4,
                        maxLines: 10,
                        maxLength: AppConstants.postMaxLength,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? l10n.createPostTextRequired
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormSection(
                      title: l10n.createPostMediaTitle,
                      subtitle: l10n.createPostMediaHint(
                        AppConstants.postMaxImages,
                        AppConstants.postMaxVideoBytes ~/ (1024 * 1024),
                      ),
                      child: MediaPicker(
                        media: _media,
                        onChanged: (media) => setState(() => _media = media),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FormSection(
                      title: l10n.createPostTagsTitle,
                      subtitle: l10n.createPostTagsHint(
                        AppConstants.postMaxTags,
                      ),
                      child: TagInput(
                        tags: _tags,
                        onChanged: (tags) => setState(() => _tags = tags),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (failure != null) ...[
                      _ErrorBanner(
                        message: failure is DataFailure
                            ? failure.message(l10n)
                            : l10n.errorUnknown,
                      ),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(
                      label: isLoading
                          ? l10n.createPostPublishing
                          : l10n.createPostSubmit,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.createPostUploadingHint,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorFondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
