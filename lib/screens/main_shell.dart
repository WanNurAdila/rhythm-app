import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:toastification/toastification.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_event.dart';
import '../blocs/focus/focus_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/streak/streak_bloc.dart';
import '../blocs/streak/streak_event.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../services/beat_service.dart';
import '../services/focus_mode_service.dart';
import '../services/focus_service.dart';
import '../services/profile_service.dart';
import '../services/streak_service.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import 'beats_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'streak_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  TaskBloc? _taskBloc;
  BeatBloc? _beatBloc;
  ProfileBloc? _profileBloc;
  StreakBloc? _streakBloc;
  FocusBloc? _focusBloc;

  static const _pages = [
    HomePage(),
    BeatsPage(),
    StreakPage(),
    ProfilePage(),
  ];

  static const _tabLabels = ['Home', 'Beats', 'Streaks', 'Profile'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_taskBloc == null) {
      final client = GraphQLProvider.of(context).value;
      final taskService = TaskService(client: client);
      final streakService = StreakService(client: client);
      _streakBloc = StreakBloc(streakService: streakService)
        ..add(const StreakLoadRequested());
      _taskBloc = TaskBloc(
        taskService: taskService,
        streakService: streakService,
        streakBloc: _streakBloc!,
      )..add(const CompletedCountLoadRequested());
      _beatBloc = BeatBloc(beatService: BeatService(client: client))
        ..add(const BeatsLoadRequested());
      _profileBloc = ProfileBloc(profileService: ProfileService(client: client))
        ..add(const ProfileLoadRequested());
      _focusBloc = FocusBloc(
        focusService: FocusService(client: client),
        taskService: taskService,
        focusModeService: FocusModeService(),
      );
    }
  }

  @override
  void dispose() {
    _taskBloc?.close();
    _beatBloc?.close();
    _profileBloc?.close();
    _streakBloc?.close();
    _focusBloc?.close();
    super.dispose();
  }

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _taskBloc!),
        BlocProvider.value(value: _beatBloc!),
        BlocProvider.value(value: _profileBloc!),
        BlocProvider.value(value: _streakBloc!),
        BlocProvider.value(value: _focusBloc!),
      ],
      child: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              title: const Text('Something went wrong'),
              description: Text(state.message),
              autoCloseDuration: const Duration(seconds: 6),
              alignment: Alignment.bottomCenter,
              showProgressBar: false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: _pages[_selectedIndex],
          bottomNavigationBar: _buildTabBar(context),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (i) => _buildTab(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final active = _selectedIndex == index;
    final color = active ? AppColors.violet : AppColors.subtle;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabIcon(index: index, active: active, color: color),
            const SizedBox(height: 3),
            Text(
              _tabLabels[index],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.index, required this.active, required this.color});
  final int index;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_rounded,
      Icons.access_time_rounded,
      Icons.local_fire_department_rounded,
      Icons.person_rounded,
    ];
    return Icon(icons[index], color: color, size: 22);
  }
}
