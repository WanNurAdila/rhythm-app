import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/authentication/authentication_state.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/authentication_form.dart';
import '../widgets/design_system.dart';

bool _isCredentialError(String? message) =>
    message != null && message.toLowerCase().contains('credential');

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthenticationBloc(authRepository: authRepository),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state.status == AuthenticationStatus.success) {
            context.go('/home');
          } else if (state.status == AuthenticationStatus.failure &&
              state.errorMessage != null &&
              !_isCredentialError(state.errorMessage)) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text('Sign in failed'),
              description: Text(state.errorMessage!),
              autoCloseDuration: const Duration(seconds: 6),
              alignment: Alignment.bottomCenter,
              showProgressBar: false,
            );
          }
        },
        child: const Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(child: _LoginBody()),
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 56, bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BrandPulseMark(size: 100),
                    const SizedBox(height: 36),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'Rhythm', style: displayText(52)),
                          TextSpan(text: '.', style: displayText(52, color: AppColors.violetBright)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'FLOW THROUGH YOUR DAY',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.subtle,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  children: [
                    const AuthenticationForm(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No account? ',
                          style: TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 13, color: AppColors.violetBright, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

