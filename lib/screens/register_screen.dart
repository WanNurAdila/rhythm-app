import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  int get _passwordStrength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[a-zA-Z]')) && p.contains(RegExp(r'[0-9]'))) score++;
    if (p.length >= 12) score++;
    return score;
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await widget.authRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );
      if (!mounted) return;
      context.go('/onboarding', extra: _displayNameController.text.trim());
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;
    final strengthColor = strength == 0 ? AppColors.faint : strength == 1 ? AppColors.hot : strength == 2 ? AppColors.warm : AppColors.success;
    final strengthLabel = ['', 'Weak', 'Good', 'Strong'][strength.clamp(0, 3)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.6),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Join Rhythm and find your flow.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 28),

                const InputLabel('Display name'),
                TextFormField(
                  controller: _displayNameController,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'How others see you'),
                  validator: (v) => _required(v, 'Display name'),
                ),
                const SizedBox(height: 12),

                const InputLabel('Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) => _required(v, 'Email'),
                ),
                const SizedBox(height: 12),

                const InputLabel('Password'),
                TextFormField(
                  controller: _passwordController,
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
                  onChanged: (_) => setState(() {}),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(3, (i) => Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
                            height: 3,
                            decoration: BoxDecoration(
                              color: i < strength ? strengthColor : AppColors.faint,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (strength > 0) Text(
                      strengthLabel,
                      style: TextStyle(fontSize: 11, color: strengthColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Create account',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.hot, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Have account? ', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(fontSize: 13, color: AppColors.violetBright, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
