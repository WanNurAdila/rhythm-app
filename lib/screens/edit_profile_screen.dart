import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _Timezone {
  const _Timezone(this.name, this.offset);
  final String name;
  final String offset;
  String get display => '$name · $offset';
}

const _timezones = [
  _Timezone('Pacific Time', 'GMT−8'),
  _Timezone('Mountain Time', 'GMT−7'),
  _Timezone('Central Time', 'GMT−6'),
  _Timezone('Eastern Time', 'GMT−5'),
  _Timezone('Atlantic Time', 'GMT−4'),
  _Timezone('UTC', 'GMT+0'),
  _Timezone('London', 'GMT+0'),
  _Timezone('Paris', 'GMT+1'),
  _Timezone('Berlin', 'GMT+1'),
  _Timezone('Istanbul', 'GMT+3'),
  _Timezone('Dubai', 'GMT+4'),
  _Timezone('Karachi', 'GMT+5'),
  _Timezone('Mumbai', 'GMT+5:30'),
  _Timezone('Dhaka', 'GMT+6'),
  _Timezone('Bangkok', 'GMT+7'),
  _Timezone('Singapore', 'GMT+8'),
  _Timezone('Tokyo', 'GMT+9'),
  _Timezone('Seoul', 'GMT+9'),
  _Timezone('Sydney', 'GMT+10'),
  _Timezone('Auckland', 'GMT+12'),
];

const _pronounOptions = [
  'he / him',
  'she / her',
  'they / them',
  'ze / zir',
  'xe / xem',
  'Prefer not to mention',
];

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  _Timezone _selectedTimezone = _timezones.first;
  Gender? _selectedGender;
  String? _selectedPronouns;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _nameController = TextEditingController(text: state.profile.displayName);
      _selectedGender = state.profile.gender;
      _selectedPronouns = state.profile.pronouns;
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _pickTimezone() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Time zone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                itemCount: _timezones.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (ctx, i) {
                  final tz = _timezones[i];
                  final selected = tz.name == _selectedTimezone.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTimezone = tz);
                      Navigator.of(ctx).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tz.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? AppColors.violetBright
                                        : AppColors.text,
                                  ),
                                ),
                                Text(
                                  tz.offset,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.subtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.violetBright,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickGender() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Gender.values.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                color: AppColors.border,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (ctx, i) {
                final gender = Gender.values[i];
                final selected = gender == _selectedGender;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGender = gender);
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _genderLabel(gender),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? AppColors.violetBright
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check,
                              size: 16, color: AppColors.violetBright),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _genderLabel(Gender gender) => switch (gender) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };

  void _pickPronouns() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pronouns',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pronounOptions.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                color: AppColors.border,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (ctx, i) {
                final option = _pronounOptions[i];
                final selected = option == _selectedPronouns;
                final isPreferNot = option == 'Prefer not to mention';
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedPronouns = option);
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? AppColors.violetBright
                                  : isPreferNot
                                  ? AppColors.muted
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.violetBright,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    context.read<ProfileBloc>().add(ProfileUpdateRequested(
      displayName: name,
      gender: _selectedGender,
      pronouns: _selectedPronouns,
      timezone: _selectedTimezone.name,
    ));
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
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.hot,
            ),
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
                          final name = state is ProfileLoaded
                              ? state.profile.displayName
                              : '';
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(22, 40, 22, 18),
                            child: Center(
                              child: RhythmAvatar(
                                size: 88,
                                seed: name,
                              ),
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
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Your display name',
                              ),
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Email'),
                            BlocBuilder<ProfileBloc, ProfileState>(
                              builder: (context, state) {
                                final email = state is ProfileLoaded
                                    ? state.profile.email
                                    : '';
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          email,
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.lock_outline,
                                        size: 13,
                                        color: AppColors.subtle,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Time zone'),
                            GestureDetector(
                              onTap: _pickTimezone,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  14,
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedTimezone.display,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.unfold_more,
                                      size: 16,
                                      color: AppColors.subtle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Gender'),
                            GestureDetector(
                              onTap: _pickGender,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedGender != null
                                            ? _genderLabel(_selectedGender!)
                                            : 'Select gender',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedGender != null
                                              ? AppColors.text
                                              : AppColors.subtle,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.unfold_more,
                                        size: 16, color: AppColors.subtle),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            const InputLabel('Pronouns'),
                            GestureDetector(
                              onTap: _pickPronouns,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  14,
                                  12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedPronouns ?? 'Select pronouns',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedPronouns != null
                                              ? AppColors.text
                                              : AppColors.subtle,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.unfold_more,
                                      size: 16,
                                      color: AppColors.subtle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
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
