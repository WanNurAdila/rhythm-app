import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    final name = state is ProfileLoaded ? state.profile.displayName : '';
    _nameController = TextEditingController(text: name);
    _pronounsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    context.read<ProfileBloc>().add(ProfileUpdateRequested(name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && _saving) {
          setState(() => _saving = false);
          Navigator.of(context).pop();
        } else if (state is ProfileError && _saving) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.hot),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              BackNavHeader(
                title: 'Edit profile',
                actionLabel: _saving ? 'Saving…' : 'Save',
                action: _saving ? null : _save,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Avatar (display only)
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          final name = state is ProfileLoaded ? state.profile.displayName : '';
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(22, 40, 22, 18),
                            child: Center(
                              child: RhythmAvatar(size: 88, initials: name.isNotEmpty ? initialsFrom(name) : '?'),
                            ),
                          );
                        },
                      ),

                      // Form fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InputLabel('Display name'),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: AppColors.text, fontSize: 14),
                              decoration: const InputDecoration(hintText: 'Your display name'),
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Email'),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                final email = state is ProfileLoaded ? state.profile.email : '';
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(email, style: const TextStyle(color: AppColors.muted, fontSize: 14))),
                                      const Icon(Icons.lock_outline, size: 13, color: AppColors.subtle),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Time zone'),
                            Container(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(child: Text('Pacific Time · GMT−8', style: TextStyle(color: AppColors.text, fontSize: 14))),
                                  Icon(Icons.chevron_right, size: 14, color: AppColors.subtle),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Pronouns'),
                            TextField(
                              controller: _pronounsController,
                              style: const TextStyle(color: AppColors.text, fontSize: 14),
                              decoration: const InputDecoration(hintText: 'e.g. they / them'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.hot),
                            ),
                            child: const Center(
                              child: Text('Delete account', style: TextStyle(color: AppColors.hot, fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
