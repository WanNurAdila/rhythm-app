import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/authentication/authentication_event.dart';
import '../blocs/authentication/authentication_state.dart';
import '../mixins/validation_mixin.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class AuthenticationForm extends StatefulWidget {
  const AuthenticationForm({super.key});

  @override
  State<AuthenticationForm> createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends State<AuthenticationForm>
    with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InputLabel('Email'),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(hintText: 'you@example.com'),
                initialValue: state.email,
                onChanged: (v) => context.read<AuthenticationBloc>().add(
                  AuthenticationEmailChanged(v),
                ),
                validator: (v) => validateEmail(v ?? ''),
              ),
              const SizedBox(height: 12),
              const InputLabel('Password'),
              TextFormField(
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.subtle,
                      size: 18,
                    ),
                  ),
                ),
                onChanged: (v) => context.read<AuthenticationBloc>().add(
                  AuthenticationPasswordChanged(v),
                ),
                validator: (v) => validatePassword(v ?? ''),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 12, color: AppColors.violetBright, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Sign in',
                isLoading: state.status == AuthenticationStatus.loading,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<AuthenticationBloc>().add(
                      const AuthenticationLoginSubmitted(),
                    );
                  }
                },
              ),
              if (state.status == AuthenticationStatus.failure && state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.hot, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
