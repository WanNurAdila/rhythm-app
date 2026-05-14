enum AuthenticationStatus { initial, loading, success, failure }

class AuthenticationState {
  final String email;
  final String password;
  final String displayName;
  final String? errorMessage;
  final AuthenticationStatus status;
  final bool isAuthenticated;

  const AuthenticationState({
    this.email = '',
    this.password = '',
    this.displayName = '',
    this.errorMessage,
    this.status = AuthenticationStatus.initial,
    this.isAuthenticated = false,
  });

  AuthenticationState copyWith({
    String? email,
    String? password,
    String? displayName,
    String? errorMessage,
    AuthenticationStatus? status,
    bool? isAuthenticated,
  }) {
    return AuthenticationState(
      email: email ?? this.email,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage,
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
