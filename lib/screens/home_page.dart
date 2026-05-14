import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_state.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/beat.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';
import 'add_task_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Beat? _selectedBeat;
  bool _initialLoadDone = false;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _selectBeat(Beat beat) {
    setState(() => _selectedBeat = beat);
    context.read<TaskBloc>().add(
      TasksLoadRequested(beat: beat.name, scheduledDate: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BeatBloc, BeatState>(
      listener: (context, state) {
        if (state is BeatLoaded && !_initialLoadDone && state.beats.isNotEmpty) {
          _initialLoadDone = true;
          final firstActive = state.beats.where((b) => b.isActive).firstOrNull ?? state.beats.first;
          _selectBeat(firstActive);
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBeatChips(),
            _buildEnergyCard(),
            _buildTaskListHeader(context),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final name = state is ProfileLoaded ? state.profile.displayName : '';
        final initials = name.isNotEmpty ? initialsFrom(name) : '?';
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.isNotEmpty ? name : '...',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.6),
                    ),
                  ],
                ),
              ),
              RhythmAvatar(size: 36, initials: initials),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBeatChips() {
    return BlocBuilder<BeatBloc, BeatState>(
      builder: (context, state) {
        if (state is! BeatLoaded) return const SizedBox(height: 36);
        final active = state.beats.where((b) => b.isActive).toList();
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: active.length,
            itemBuilder: (_, i) {
              final beat = active[i];
              final info = BeatInfo.forType(beat.type);
              final selected = _selectedBeat?.id == beat.id;
              return GestureDetector(
                onTap: () => _selectBeat(beat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? info.bgColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? info.color.withValues(alpha: 0.2) : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: info.color,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: info.color.withValues(alpha: 0.5), blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        info.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: selected ? info.color : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnergyCard() {
    final hour = DateTime.now().hour;
    final int level;
    final String label;
    final String sub;
    if (hour >= 6 && hour < 10) {
      level = 4; label = 'High'; sub = 'best for deep work';
    } else if (hour >= 10 && hour < 13) {
      level = 5; label = 'Peak'; sub = 'max focus window';
    } else if (hour >= 13 && hour < 15) {
      level = 2; label = 'Low'; sub = 'good for light tasks';
    } else if (hour >= 15 && hour < 18) {
      level = 3; label = 'Medium'; sub = 'steady productivity';
    } else {
      level = 2; label = 'Low'; sub = 'wind down time';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: RhythmCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENERGY LEVEL',
                    style: TextStyle(fontSize: 11, color: AppColors.subtle, letterSpacing: 0.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                      ),
                      const SizedBox(width: 8),
                      Text('· $sub', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
            EnergyDots(level: level),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListHeader(BuildContext context) {
    final beatName = _selectedBeat != null ? '${BeatInfo.forType(_selectedBeat!.type).label} tasks' : 'Tasks';
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Row(
        children: [
          Text(beatName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (_selectedBeat != null) {
                AddTaskSheet.show(context, taskBloc: context.read<TaskBloc>(), defaultBeat: _selectedBeat!.name);
              }
            },
            child: Row(
              children: const [
                Icon(Icons.add, size: 11, color: AppColors.violetBright),
                SizedBox(width: 2),
                Text('Add', style: TextStyle(fontSize: 12, color: AppColors.violetBright, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
        }
        if (state is TaskLoaded) {
          if (state.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle_outline, color: AppColors.subtle, size: 32),
                  SizedBox(height: 8),
                  Text('No tasks yet', style: TextStyle(color: AppColors.subtle, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            itemCount: state.tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TaskCard(task: state.tasks[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final energyColor = switch (task.energy) {
      TaskEnergy.low => AppColors.success,
      TaskEnergy.medium => AppColors.warm,
      TaskEnergy.high => AppColors.hot,
    };
    final energyBg = switch (task.energy) {
      TaskEnergy.low => AppColors.successSoft,
      TaskEnergy.medium => AppColors.warmSoft,
      TaskEnergy.high => AppColors.hotSoft,
    };
    final energyLabel = switch (task.energy) {
      TaskEnergy.low => 'Low',
      TaskEnergy.medium => 'Med',
      TaskEnergy.high => 'High',
    };

    return RhythmCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<TaskBloc>().add(TaskCompleteRequested(task.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.violet : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: task.isCompleted ? null : Border.all(color: AppColors.borderStrong, width: 1.5),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted ? AppColors.subtle : AppColors.text,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.subtle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.durationMinutes} min',
                  style: const TextStyle(fontSize: 11, color: AppColors.subtle),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: energyBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              energyLabel,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: energyColor),
            ),
          ),
        ],
      ),
    );
  }
}
