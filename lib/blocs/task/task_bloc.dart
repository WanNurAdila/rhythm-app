import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../services/streak_service.dart';
import '../../services/task_service.dart';
import '../streak/streak_bloc.dart';
import '../streak/streak_event.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required TaskService taskService,
    required StreakService streakService,
    required StreakBloc streakBloc,
  })  : _taskService = taskService,
        _streakService = streakService,
        _streakBloc = streakBloc,
        super(const TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskAddRequested>(_onTaskAddRequested);
    on<TaskCompleteRequested>(_onTaskCompleteRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskRefreshRequested>(_onTaskRefreshRequested);
    on<CompletedCountLoadRequested>(_onCompletedCountLoadRequested);
  }

  final TaskService _taskService;
  final StreakService _streakService;
  final StreakBloc _streakBloc;
  String? _lastBeatId;
  DateTime? _lastScheduledDate;
  int? _completedCount;

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    _lastBeatId = event.beatId;
    _lastScheduledDate = event.scheduledDate;

    emit(const TaskLoading());
    try {
      final tasks = await _taskService.getTasks(
        beatId: event.beatId,
        scheduledDate: event.scheduledDate,
      );
      emit(TaskLoaded(tasks: tasks, completedCount: _completedCount));
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }

  Future<void> _onTaskAddRequested(
    TaskAddRequested event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    emit(const TaskLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated.');

      final task = await _taskService.addTask(
        userId: userId,
        beatId: event.beatId,
        title: event.title,
        priority: event.priority,
        durationMinutes: event.durationMinutes,
        scheduledDate: event.scheduledDate,
      );

      final existing = current is TaskLoaded ? current.tasks : <Task>[];
      emit(TaskLoaded(tasks: [...existing, task], completedCount: _completedCount));

      // Adding a task means the beat is no longer fully done — revoke completion.
      try {
        await _streakService.deleteBeatCompletion(
          userId: userId,
          beatId: event.beatId,
          date: event.scheduledDate,
        );
      } catch (_) {}
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }

  Future<void> _onTaskCompleteRequested(
    TaskCompleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    if (current is! TaskLoaded) return;

    try {
      await _taskService.completeTask(event.id);
      final now = DateTime.now();
      final tasks = current.tasks
          .map((t) => t.id == event.id
              ? t.copyWith(isCompleted: true, completedAt: now)
              : t)
          .toList();
      if (_completedCount != null) _completedCount = _completedCount! + 1;
      emit(current.copyWith(tasks: tasks, completedCount: _completedCount));

      final completingTask = current.tasks.where((t) => t.id == event.id).firstOrNull;
      if (completingTask != null) {
        NotificationService.instance.showTaskComplete(completingTask.title).ignore();
      }

      // If all tasks in the beat are now done, let StreakBloc record the completion.
      final allDone = tasks.every((t) => t.isCompleted);
      if (allDone) {
        final completedTask = current.tasks.where((t) => t.id == event.id).firstOrNull;
        if (completedTask != null) {
          _streakBloc.add(BeatCompletionRecorded(
            beatId: completedTask.beatId,
            tasksTotal: tasks.length,
            tasksDone: tasks.length,
          ));
        }
      }
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    final current = state;
    if (current is! TaskLoaded) return;

    try {
      await _taskService.deleteTask(event.id);
      final tasks = current.tasks.where((t) => t.id != event.id).toList();
      emit(current.copyWith(tasks: tasks));
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }

  Future<void> _onTaskRefreshRequested(
    TaskRefreshRequested event,
    Emitter<TaskState> emit,
  ) async {
    final beatId = _lastBeatId;
    final scheduledDate = _lastScheduledDate;
    if (beatId == null || scheduledDate == null) return;

    emit(const TaskLoading());
    try {
      final tasks = await _taskService.getTasks(
        beatId: beatId,
        scheduledDate: scheduledDate,
      );
      emit(TaskLoaded(tasks: tasks, completedCount: _completedCount));
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }

  Future<void> _onCompletedCountLoadRequested(
    CompletedCountLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      _completedCount = await _taskService.getCompletedTaskCount(userId: userId);
      final current = state;
      if (current is TaskLoaded) {
        emit(current.copyWith(completedCount: _completedCount));
      }
    } catch (_) {
      // Best-effort — profile stat, non-critical.
    }
  }
}
