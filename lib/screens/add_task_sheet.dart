import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';
import '../blocs/task/task_state.dart';
import '../models/task.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  static void show(BuildContext context, {required TaskBloc taskBloc}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          BlocProvider.value(value: taskBloc, child: const AddTaskSheet()),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  String? selectedBeat;
  String? selectedEnergy;
  String? selectedDuration;
  String? _errorMessage;
  bool _isSubmitting = false;
  final _taskNameController = TextEditingController();

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
    if (selectedEnergy == null) {
      setState(() => _errorMessage = 'Please select an energy level.');
      return;
    }

    final energy = selectedEnergy!.toLowerCase();
    final durationMinutes = selectedDuration != null
        ? int.tryParse(selectedDuration!.split(' ').first) ??
              defaultDuration(energy)
        : defaultDuration(energy);

    setState(() => _isSubmitting = true);

    context.read<TaskBloc>().add(
      TaskAddRequested(
        beat: selectedBeat!,
        title: title,
        energy: energy,
        durationMinutes: durationMinutes,
        scheduledDate: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is TaskLoaded) {
          Navigator.of(context).pop();
        } else if (state is TaskError) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Task',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Task Name',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _taskNameController,
              decoration: InputDecoration(
                hintText: 'Enter task name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Beat',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _PillGroup(
              options: const ['Morning', 'Deep Work', 'Evening'],
              selected: selectedBeat,
              onSelected: (value) => setState(() => selectedBeat = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Energy',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _PillGroup(
              options: const ['Low', 'Medium', 'High'],
              selected: selectedEnergy,
              onSelected: (value) => setState(() {
                selectedEnergy = value;
                if (value == 'High') {
                  selectedDuration = '45 mins';
                } else if (value == 'Medium') {
                  selectedDuration = '30 mins';
                } else if (value == 'Low') {
                  selectedDuration = '15 mins';
                }
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Duration',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _PillGroup(
              options: const ['15 mins', '30 mins', '45 mins', '60 mins'],
              selected: selectedDuration,
              onSelected: (value) => setState(() => selectedDuration = value),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Task'),
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

class _PillGroup extends StatelessWidget {
  const _PillGroup({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ElevatedButton(
          onPressed: () => onSelected(option),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF4A3F8F)
                : const Color(0xFF2A2A35),
            foregroundColor: isSelected
                ? const Color(0xFFE8E5FF)
                : const Color(0xFF808088),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(option),
        );
      }).toList(),
    );
  }
}
