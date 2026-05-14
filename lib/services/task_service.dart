import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/task.dart';

const _taskFields = '''
  id
  user_id
  beat
  title
  energy
  duration_minutes
  is_completed
  scheduled_date
  completed_at
  created_at
''';

const _getTasksQuery = '''
  query GetTasks(\$beat: String!, \$scheduledDate: Date!) {
    tasksCollection(
      filter: {
        beat: { eq: \$beat }
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

const _addTaskMutation = '''
  mutation AddTask(
    \$userId: UUID!
    \$beat_id: String!
    \$title: String!
    \$energy: String!
    \$durationMinutes: Int!
    \$scheduledDate: Date!
  ) {
    insertIntoTasksCollection(objects: [{
      user_id: \$userId
      beat_id: \$beat_id
      title: \$title
      energy: \$energy
      duration_minutes: \$durationMinutes
      scheduled_date: \$scheduledDate
      is_completed: false
    }]) {
      records {
        $_taskFields
      }
    }
  }
''';

const _completeTaskMutation = '''
  mutation CompleteTask(\$id: UUID!, \$completedAt: Datetime!) {
    updateTasksCollection(
      filter: { id: { eq: \$id } }
      set: { is_completed: true, completed_at: \$completedAt }
    ) {
      records {
        $_taskFields
      }
    }
  }
''';

const _deleteTaskMutation = '''
  mutation DeleteTask(\$id: UUID!) {
    deleteFromTasksCollection(filter: { id: { eq: \$id } }) {
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
    required String beat,
    required DateTime scheduledDate,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getTasksQuery),
        variables: {
          'beat': beat,
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

  Future<Task> addTask({
    required String userId,
    required String beat,
    required String title,
    required String energy,
    required int durationMinutes,
    required DateTime scheduledDate,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_addTaskMutation),
        variables: {
          'userId': userId,
          'beat': beat,
          'title': title,
          'energy': energy,
          'durationMinutes': durationMinutes,
          'scheduledDate': _formatDate(scheduledDate),
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['insertIntoTasksCollection']['records'] as List).first;
    return Task.fromJson(record as Map<String, dynamic>);
  }

  Future<Task> completeTask(String id) async {
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

    final record =
        (result.data!['updateTasksCollection']['records'] as List).first;
    return Task.fromJson(record as Map<String, dynamic>);
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
