import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    final isValid = await widget.authRepository.isTokenValid();
    if (!mounted) return;
    if (isValid) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: BrandPulseMark(size: 80),
      ),
    );
  }
}
