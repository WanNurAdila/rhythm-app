import '../../models/task.dart';

abstract class TaskState {
  const TaskState();
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final int? completedCount;

  const TaskLoaded({required this.tasks, this.completedCount});

  TaskLoaded copyWith({List<Task>? tasks, int? completedCount}) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});
}
