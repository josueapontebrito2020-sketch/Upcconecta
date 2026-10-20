import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/data_failure.dart';
import '../../../../core/errors/data_failure_message.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_decoration.dart';
import '../providers/profile_providers.dart';
import '../widgets/user_list_tile.dart';

/// Buscar personas (amigos, compañeros, profesores) por nombre o usuario.
class SearchUsersPage extends ConsumerStatefulWidget {
  const SearchUsersPage({super.key});

  @override
  ConsumerState<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends ConsumerState<SearchUsersPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Busca 400 ms después de dejar de escribir.
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final Widget results;
    if (_query.length < 2) {
      results = _Hint(icon: Icons.person_search_outlined, text: l10n.searchUsersHint);
    } else {
      results = ref
          .watch(userSearchProvider(_query))
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _Hint(
              icon: Icons.wifi_off_rounded,
              text: error is DataFailure
                  ? error.message(l10n)
                  : l10n.errorUnknown,
            ),
            data: (people) => people.isEmpty
                ? _Hint(
                    icon: Icons.search_off_rounded,
                    text: l10n.searchUsersEmpty(_query),
                  )
                : ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: people.length,
                    itemBuilder: (context, index) =>
                        UserListTile(user: people[index]),
                  ),
          );
    }

    return Scaffold(
      backgroundColor: AppColors.superficie,
      appBar: AppBar(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: textTheme.bodyLarge,
            decoration: appInputDecoration(
              label: l10n.searchUsersTitle,
              hint: l10n.searchUsersFieldHint,
            ).copyWith(
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onChanged: _onChanged,
            onSubmitted: (text) => setState(() => _query = text.trim()),
          ),
        ),
      ),
      body: results,
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.tintaSuave),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
