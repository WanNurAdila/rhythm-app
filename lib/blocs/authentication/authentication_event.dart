abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationEmailChanged extends AuthenticationEvent {
  final String email;

  const AuthenticationEmailChanged(this.email);
}

class AuthenticationPasswordChanged extends AuthenticationEvent {
  final String password;

  const AuthenticationPasswordChanged(this.password);
}

class AuthenticationDisplayNameChanged extends AuthenticationEvent {
  final String displayName;

  const AuthenticationDisplayNameChanged(this.displayName);
}

class AuthenticationRegisterSubmitted extends AuthenticationEvent {
  const AuthenticationRegisterSubmitted();
}

class AuthenticationLoginSubmitted extends AuthenticationEvent {
  const AuthenticationLoginSubmitted();
}

class AuthenticationLogoutRequested extends AuthenticationEvent {
  const AuthenticationLogoutRequested();
}
