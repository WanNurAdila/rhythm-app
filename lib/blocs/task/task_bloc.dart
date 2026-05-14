import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({required TaskService taskService})
      : _taskService = taskService,
        super(const TaskInitial()) {
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskAddRequested>(_onTaskAddRequested);
    on<TaskCompleteRequested>(_onTaskCompleteRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskRefreshRequested>(_onTaskRefreshRequested);
  }

  final TaskService _taskService;
  String? _lastBeatId;
  DateTime? _lastScheduledDate;

  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    _lastBeatId = event.beat;
    _lastScheduledDate = event.scheduledDate;

    emit(const TaskLoading());
    try {
      final tasks = await _taskService.getTasks(
        beat: event.beat,
        scheduledDate: event.scheduledDate,
      );
      emit(TaskLoaded(tasks: tasks));
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
        beat: event.beat,
        title: event.title,
        energy: event.energy,
        durationMinutes: event.durationMinutes,
        scheduledDate: event.scheduledDate,
      );

      final existing = current is TaskLoaded ? current.tasks : <Task>[];
      emit(TaskLoaded(tasks: [...existing, task]));
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
      final updated = await _taskService.completeTask(event.id);
      final tasks =
          current.tasks.map((t) => t.id == event.id ? updated : t).toList();
      emit(current.copyWith(tasks: tasks));
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
        beat: beatId,
        scheduledDate: scheduledDate,
      );
      emit(TaskLoaded(tasks: tasks));
    } catch (error) {
      emit(TaskError(message: error.toString()));
    }
  }
}
