import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/beat/beat_bloc.dart';
import '../blocs/beat/beat_state.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.defaultBeat});

  final String? defaultBeat;

  static void show(
    BuildContext context, {
    required TaskBloc taskBloc,
    String? defaultBeat,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: taskBloc),
          BlocProvider.value(value: context.read<BeatBloc>()),
        ],
        child: AddTaskSheet(defaultBeat: defaultBeat),
      ),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  String? selectedBeat;
  String? selectedPriority;
  String? selectedDuration;
  String? _errorMessage;
  bool _isSubmitting = false;
  final _taskNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedBeat = widget.defaultBeat;
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMessage = null);
    final title = _taskNameController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter a task name.');
      return;
    }
    if (selectedBeat == null) {
      setState(() => _errorMessage = 'Please select a beat.');
      return;
    }
    if (selectedPriority == null) {
      setState(() => _errorMessage = 'Please select an energy level.');
      return;
    }

    final priority = selectedPriority!.toLowerCase();
    final durationMinutes = selectedDuration != null
        ? int.tryParse(selectedDuration!.replaceAll(RegExp(r'[^0-9]'), '')) ??
              defaultDuration(priority)
        : defaultDuration(priority);

    setState(() => _isSubmitting = true);
    context.read<TaskBloc>().add(
      TaskAddRequested(
        beatId: selectedBeat!,
        title: title,
        priority: priority,
        durationMinutes: durationMinutes,
        scheduledDate: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is TaskLoaded) {
          Navigator.of(context).pop();
        } else if (state is TaskError) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        padding: EdgeInsets.fromLTRB(22, 12, 22, bottom + 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Center(
              child: Text(
                'New task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const InputLabel('Task name'),
            TextField(
              controller: _taskNameController,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
              ),
              autofocus: true,
            ),
            const SizedBox(height: 14),

            const InputLabel('Beat'),
            _BeatChips(
              selected: selectedBeat,
              onSelected: (v) => setState(() => selectedBeat = v),
            ),
            const SizedBox(height: 14),

            const InputLabel('Priority'),
            Row(
              children: ['Low', 'Medium', 'High']
                  .map(
                    (e) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: e != 'High' ? 6 : 0),
                        child: SelectorChip(
                          label: e,
                          selected: selectedPriority == e,
                          onTap: () => setState(() {
                            selectedPriority = e;
                          }),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),

            const InputLabel('Duration'),
            Row(
              children: ['15 min', '30 min', '45 min', '60 min']
                  .map(
                    (d) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: d != '60 min' ? 6 : 0),
                        child: SelectorChip(
                          label: d,
                          selected: selectedDuration == d,
                          onTap: () => setState(() => selectedDuration = d),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.hot, fontSize: 12),
              ),
            ],
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Add task',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BeatChips extends StatelessWidget {
  const _BeatChips({required this.selected, required this.onSelected});
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeatBloc, BeatState>(
      builder: (context, state) {
        final beats = state is BeatLoaded
            ? state.beats.where((b) => b.isActive).toList()
            : <dynamic>[];
        if (beats.isEmpty) {
          return const _FallbackBeatChips(selected: null, onSelected: null);
        }
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: beats
              .map(
                (beat) => SelectorChip(
                  label: beat.name,
                  selected: selected == beat.id,
                  onTap: () => onSelected(beat.id),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

// Fallback when BeatBloc isn't available
class _FallbackBeatChips extends StatelessWidget {
  const _FallbackBeatChips({required this.selected, required this.onSelected});
  final String? selected;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: ['Morning', 'Deep Work', 'Evening']
          .map(
            (b) => SelectorChip(
              label: b,
              selected: selected == b,
              onTap: () => onSelected?.call(b),
            ),
          )
          .toList(),
    );
  }
}
