import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/theme/app_theme.dart';
import 'package:happyn_mobile/features/auth/presentation/auth_controller.dart';

/// Phone number, then the code sent to it. One screen, two steps, because they
/// are one decision: "prove this number is yours".
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(authFlowProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: switch (flow.step) {
                AuthStep.phone => const _PhoneStep(),
                AuthStep.code => const _CodeStep(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.subtitle, required this.title});

  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.error, fontSize: 13),
      ),
    );
  }
}

/// The app's one primary action button.
class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.busy,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final bool busy;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryFixedDim,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          foregroundColor: AppColors.onSecondaryFixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.onSurfaceVariant,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
      ),
    );
  }
}

InputDecoration authFieldDecoration({String? hint, String? prefix}) =>
    InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      fillColor: AppColors.surfaceContainerLow,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondaryFixedDim),
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.outline),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );

class _PhoneStep extends ConsumerStatefulWidget {
  const _PhoneStep();

  @override
  ConsumerState<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<_PhoneStep> {
  final _controller = TextEditingController();

  /// India only for now, which is where Happyen launches. Kept as a named
  /// constant rather than sprinkled through the widget so adding a country
  /// picker later is one place.
  static const _dialCode = '+91';
  static const _nationalDigits = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.length == _nationalDigits;

  void _submit() {
    if (!_valid) return;
    ref
        .read(authFlowProvider.notifier)
        .requestCode('$_dialCode${_controller.text}');
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(authFlowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading(
          subtitle: 'Your number is how you sign in. We send a code to check '
              'it is yours.',
          title: 'What is your number?',
        ),
        const SizedBox(height: 32),
        TextField(
          autofocus: true,
          controller: _controller,
          decoration: authFieldDecoration(
            hint: '98765 43210',
            prefix: '$_dialCode  ',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_nationalDigits),
          ],
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          textInputAction: TextInputAction.done,
        ),
        _ErrorText(flow.error),
        const SizedBox(height: 28),
        AuthButton(
          busy: flow.busy,
          label: 'SEND CODE',
          onPressed: _valid ? _submit : null,
        ),
      ],
    );
  }
}

class _CodeStep extends ConsumerStatefulWidget {
  const _CodeStep();

  @override
  ConsumerState<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends ConsumerState<_CodeStep> {
  final _controller = TextEditingController();

  static const _codeLength = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.length == _codeLength;

  void _submit() {
    if (!_valid) return;
    ref.read(authFlowProvider.notifier).submitCode(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(authFlowProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(
          subtitle: 'We sent a $_codeLength-digit code to ${flow.phoneE164}.',
          title: 'Enter your code',
        ),
        const SizedBox(height: 32),
        TextField(
          autofocus: true,
          controller: _controller,
          decoration: authFieldDecoration(hint: '123456'),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_codeLength),
          ],
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {});
            // The code is a fixed length, so the last digit is the submit.
            if (value.length == _codeLength) _submit();
          },
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 12,
          ),
          textInputAction: TextInputAction.done,
        ),
        _ErrorText(flow.error),
        const SizedBox(height: 28),
        AuthButton(
          busy: flow.busy,
          label: 'VERIFY',
          onPressed: _valid ? _submit : null,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: flow.busy
                  ? null
                  : ref.read(authFlowProvider.notifier).editPhone,
              child: const Text(
                'Change number',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: flow.busy
                  ? null
                  : ref.read(authFlowProvider.notifier).resendCode,
              child: const Text(
                'Resend',
                style: TextStyle(color: AppColors.tertiaryFixedDim),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
