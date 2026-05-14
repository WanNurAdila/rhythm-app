import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/authentication/authentication_state.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/authentication_form.dart';
import '../widgets/design_system.dart';

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
          }
        },
        child: const Scaffold(
          backgroundColor: AppColors.bg,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const BrandPulseMark(size: 68),
          const SizedBox(height: 24),
          Text(
            'Rhythm',
            style: displayText(44),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flow through your day.',
            style: TextStyle(fontSize: 13, color: AppColors.muted, letterSpacing: 0.1),
          ),
          const SizedBox(height: 56),
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
    );
  }
}

