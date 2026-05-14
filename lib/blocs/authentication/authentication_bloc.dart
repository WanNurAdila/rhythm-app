import 'package:bloc/bloc.dart';
import '../../repositories/auth_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthenticationState()) {
    on<AuthenticationEmailChanged>(_onEmailChanged);
    on<AuthenticationPasswordChanged>(_onPasswordChanged);
    on<AuthenticationDisplayNameChanged>(_onDisplayNameChanged);
    on<AuthenticationRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthenticationLoginSubmitted>(_onLoginSubmitted);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(
    AuthenticationEmailChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    emit(state.copyWith(email: event.email, errorMessage: null));
  }

  void _onPasswordChanged(
    AuthenticationPasswordChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    emit(state.copyWith(password: event.password, errorMessage: null));
  }

  void _onDisplayNameChanged(
    AuthenticationDisplayNameChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    emit(state.copyWith(displayName: event.displayName, errorMessage: null));
  }

  Future<void> _onRegisterSubmitted(
    AuthenticationRegisterSubmitted event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading, errorMessage: null));

    try {
      await _authRepository.register(
        email: state.email,
        password: state.password,
        displayName: state.displayName,
      );
      emit(state.copyWith(
        status: AuthenticationStatus.success,
        isAuthenticated: true,
        email: '',
        password: '',
        displayName: '',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthenticationStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoginSubmitted(
    AuthenticationLoginSubmitted event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading, errorMessage: null));

    try {
      await _authRepository.login(
        email: state.email,
        password: state.password,
      );
      emit(state.copyWith(
        status: AuthenticationStatus.success,
        isAuthenticated: true,
        email: '',
        password: '',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthenticationStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await _authRepository.logout();
      emit(const AuthenticationState(
        status: AuthenticationStatus.initial,
        isAuthenticated: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AuthenticationStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
