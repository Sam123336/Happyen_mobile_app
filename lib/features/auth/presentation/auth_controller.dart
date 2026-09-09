import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happyn_mobile/core/auth/auth_gateway.dart';
import 'package:happyn_mobile/core/providers.dart';

/// Which step of sign-in the user is on.
enum AuthStep { phone, code }

class AuthFlowState {
  const AuthFlowState({
    this.busy = false,
    this.error,
    this.phoneE164 = '',
    this.step = AuthStep.phone,
  });

  final bool busy;
  final String? error;
  final String phoneE164;
  final AuthStep step;

  AuthFlowState copyWith({
    bool? busy,
    String? phoneE164,
    AuthStep? step,
    // Errors clear on the next action rather than lingering, so this is not a
    // `String?` parameter that cannot express "clear it".
    bool clearError = false,
    String? error,
  }) => AuthFlowState(
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    phoneE164: phoneE164 ?? this.phoneE164,
    step: step ?? this.step,
  );
}

/// Drives phone → code → session. It owns no navigation: [AuthGate] watches
/// the session itself, so a session restored on launch takes the same path as
/// one just created here.
class AuthFlow extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() => const AuthFlowState();

  AuthGateway get _gateway => ref.read(authGatewayProvider);

  Future<void> requestCode(String phoneE164) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _gateway.requestOtp(phoneE164);
      state = state.copyWith(
        busy: false,
        phoneE164: phoneE164,
        step: AuthStep.code,
      );
    } on AuthSessionException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    }
  }

  Future<void> submitCode(String code) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await _gateway.verifyOtp(phoneE164: state.phoneE164, code: code);
      // Deliberately no state change on success: the session arrives through
      // authUserProvider and AuthGate swaps the screen out from under this.
    } on AuthSessionException catch (error) {
      state = state.copyWith(
        busy: false,
        error: error.isInvalidCode
            ? 'That code is not right. Check it and try again.'
            : error.message,
      );
    }
  }

  Future<void> resendCode() => requestCode(state.phoneE164);

  void editPhone() =>
      state = state.copyWith(clearError: true, step: AuthStep.phone);
}

final authFlowProvider = NotifierProvider<AuthFlow, AuthFlowState>(
  AuthFlow.new,
);
