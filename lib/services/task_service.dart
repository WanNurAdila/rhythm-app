import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/task.dart';

const _taskFields = '''
  id
  user_id
  beat_id
  title
  priority
  duration_minutes
  is_completed
  scheduled_date
  completed_at
  created_at
''';

const _getTasksQuery = '''
  query GetTasks(\$beatId: UUID!, \$scheduledDate: Date!) {
    tasksCollection(
      filter: {
        beat_id: { eq: \$beatId }
        scheduled_date: { eq: \$scheduledDate }
      }
      orderBy: [{ created_at: AscNullsLast }]
    ) {
      edges {
        node {
          $_taskFields
        }
      }
    }
  }
''';

const _getBeatTasksQuery = '''
  query GetBeatTasks(\$beatId: UUID!) {
    tasksCollection(
      filter: { beat_id: { eq: \$beatId } }
      orderBy: [{ scheduled_date: AscNullsLast }]
    ) {
      edges {
        node {
          id
          beat_id
          title
          priority
          duration_minutes
          is_completed
          scheduled_date
          completed_at
        }
      }
    }
  }
''';

const _addTaskMutation = '''
  mutation AddTask(
    \$userId: UUID!
    \$beatId: UUID!
    \$title: String!
    \$priority: opaque
    \$durationMinutes: Int!
    \$scheduledDate: Date!
  ) {
    insertIntotasksCollection(objects: [{
      user_id: \$userId
      beat_id: \$beatId
      title: \$title
      priority: \$priority
      duration_minutes: \$durationMinutes
      scheduled_date: \$scheduledDate
      is_completed: false
    }]) {
      records {
        id
        user_id
        beat_id
        title
        priority
        duration_minutes
        is_completed
        scheduled_date
        created_at
      }
    }
  }
''';

const _completeTaskMutation = '''
  mutation CompleteTask(\$id: UUID!, \$completedAt: Datetime!) {
    updatetasksCollection(
      filter: { id: { eq: \$id } }
      set: {
        is_completed: true
        completed_at: \$completedAt
      }
    ) {
      records {
        id
        is_completed
        completed_at
      }
    }
  }
''';

const _updateTaskMutation = '''
  mutation UpdateTask(
    \$id: UUID!
    \$title: String!
    \$priority: opaque
    \$durationMinutes: Int!
    \$beatId: UUID!
    \$scheduledDate: Date!
  ) {
    updatetasksCollection(
      filter: { id: { eq: \$id } }
      set: {
        title: \$title
        priority: \$priority
        duration_minutes: \$durationMinutes
        beat_id: \$beatId
        scheduled_date: \$scheduledDate
      }
    ) {
      records {
        id
        title
        priority
        duration_minutes
        beat_id
        scheduled_date
      }
    }
  }
''';

const _getCompletedCountQuery = '''
  query GetCompletedTaskCount(\$userId: UUID!) {
    tasksCollection(
      filter: {
        user_id: { eq: \$userId }
        is_completed: { eq: true }
      }
    ) {
      edges {
        node {
          id
        }
      }
    }
  }
''';

const _deleteTaskMutation = '''
  mutation DeleteTask(\$id: UUID!) {
    deleteFromtasksCollection(
      filter: { id: { eq: \$id } }
      atMost: 1
    ) {
      records {
        id
      }
    }
  }
''';

class TaskService {
  TaskService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<List<Task>> getTasks({
    required String beatId,
    required DateTime scheduledDate,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getTasksQuery),
        variables: {
          'beatId': beatId,
          'scheduledDate': _formatDate(scheduledDate),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges = result.data!['tasksCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => Task.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<int> getCompletedTaskCount({required String userId}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getCompletedCountQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges = result.data!['tasksCollection']['edges'] as List<dynamic>;
    return edges.length;
  }

  Future<List<Task>> getBeatTasks({required String beatId}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getBeatTasksQuery),
        variables: {'beatId': beatId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges = result.data!['tasksCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => Task.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<Task> addTask({
    required String userId,
    required String beatId,
    required String title,
    required String priority,
    required int durationMinutes,
    required DateTime scheduledDate,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_addTaskMutation),
        variables: {
          'userId': userId,
          'beatId': beatId,
          'title': title,
          'priority': priority,
          'durationMinutes': durationMinutes,
          'scheduledDate': _formatDate(scheduledDate),
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['insertIntotasksCollection']['records'] as List).first;
    return Task.fromJson(record as Map<String, dynamic>);
  }

  Future<void> completeTask(String id) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_completeTaskMutation),
        variables: {
          'id': id,
          'completedAt': DateTime.now().toUtc().toIso8601String(),
        },
      ),
    );

    _checkErrors(result);
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String priority,
    required int durationMinutes,
    required String beatId,
    required DateTime scheduledDate,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateTaskMutation),
        variables: {
          'id': id,
          'title': title,
          'priority': priority,
          'durationMinutes': durationMinutes,
          'beatId': beatId,
          'scheduledDate': _formatDate(scheduledDate),
        },
      ),
    );

    _checkErrors(result);
  }

  Future<void> deleteTask(String id) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_deleteTaskMutation),
        variables: {'id': id},
      ),
    );

    _checkErrors(result);
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _checkErrors(QueryResult result) {
    if (result.hasException) {
      final message = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
