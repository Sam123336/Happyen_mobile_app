import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/network/api_client.dart';
import 'package:happyn_mobile/core/providers.dart';
import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/auth/presentation/sign_in_screen.dart';

/// Shown once, after the number is verified and before the city opens: the
/// account exists at this point, but it has no name yet.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

enum _NameCheck { unknown, checking, free, taken, invalid }

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _displayName = TextEditingController();
  final _username = TextEditingController();

  Timer? _debounce;
  _NameCheck _check = _NameCheck.unknown;
  bool _busy = false;
  String? _error;

  /// Matches `profiles_username_format_ck` in the database, so the client
  /// rejects what the column would reject anyway.
  static final _usernamePattern = RegExp(r'^[a-z0-9_]{3,30}$');

  @override
  void dispose() {
    _debounce?.cancel();
    _displayName.dispose();
    _username.dispose();
    super.dispose();
  }

  bool get _ready =>
      _check == _NameCheck.free && _displayName.text.trim().isNotEmpty;

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    if (!_usernamePattern.hasMatch(value)) {
      setState(
        () => _check = value.isEmpty ? _NameCheck.unknown : _NameCheck.invalid,
      );
      return;
    }

    setState(() => _check = _NameCheck.checking);
    // One request per pause in typing rather than one per keystroke.
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final free = await ref
            .read(profileRepositoryProvider)
            .isUsernameAvailable(value);
        if (!mounted || _username.text != value) return;
        setState(() => _check = free ? _NameCheck.free : _NameCheck.taken);
      } on Object {
        // An unreachable check must not block the claim: the 409 on submit is
        // the real answer, so let the user press on.
        if (mounted) setState(() => _check = _NameCheck.free);
      }
    });
  }

  Future<void> _submit() async {
    if (!_ready || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            displayName: _displayName.text.trim(),
            username: _username.text,
          );
      // The gate re-reads the profile and moves on to the city.
      ref.invalidate(currentProfileProvider);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _check = error.statusCode == 409 ? _NameCheck.taken : _check;
        _error = error.statusCode == 409
            ? 'Someone just took that name. Try another.'
            : 'Could not save that. Check your connection and try again.';
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not save that. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make it yours',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A name people see, and a handle they can find you by.',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _FieldLabel('YOUR NAME'),
                  const SizedBox(height: 8),
                  TextField(
                    autofocus: true,
                    controller: _displayName,
                    decoration: authFieldDecoration(hint: 'Sam'),
                    maxLength: 80,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 17,
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('USERNAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _username,
                    decoration: authFieldDecoration(hint: 'sam', prefix: '@'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]')),
                      LengthLimitingTextInputFormatter(30),
                      TextInputFormatter.withFunction(
                        (_, next) =>
                            next.copyWith(text: next.text.toLowerCase()),
                      ),
                    ],
                    onChanged: _onUsernameChanged,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 17,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 8),
                  _CheckHint(check: _check),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  AuthButton(
                    busy: _busy,
                    label: 'ENTER THE CITY',
                    onPressed: _ready ? _submit : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.onSurfaceVariant,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    ),
  );
}

class _CheckHint extends StatelessWidget {
  const _CheckHint({required this.check});

  final _NameCheck check;

  @override
  Widget build(BuildContext context) {
    final (color, text) = switch (check) {
      _NameCheck.unknown => (AppColors.onSurfaceVariant, '3–30 letters, numbers or _'),
      _NameCheck.checking => (AppColors.onSurfaceVariant, 'Checking…'),
      _NameCheck.free => (AppColors.tertiaryFixedDim, 'That one is free'),
      _NameCheck.taken => (AppColors.error, 'Already taken'),
      _NameCheck.invalid => (
        AppColors.error,
        '3–30 characters: letters, numbers or _',
      ),
    };

    return Text(text, style: TextStyle(color: color, fontSize: 12));
  }
}
