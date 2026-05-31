import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/focus_session.dart';

const _startSessionMutation = '''
  mutation StartFocusSession(
    \$userId: UUID!
    \$taskId: UUID!
    \$beatId: UUID!
    \$startedAt: Datetime!
  ) {
    insertIntofocusSessionsCollection(objects: [{
      user_id: \$userId
      task_id: \$taskId
      beat_id: \$beatId
      started_at: \$startedAt
      completed: false
    }]) {
      records {
        id
        user_id
        task_id
        beat_id
        started_at
        completed
      }
    }
  }
''';

const _endSessionMutation = '''
  mutation EndFocusSession(
    \$id: UUID!
    \$endedAt: Datetime!
    \$durationSeconds: Int!
    \$completed: Boolean!
  ) {
    updatefocusSessionsCollection(
      filter: { id: { eq: \$id } }
      set: {
        ended_at: \$endedAt
        duration_seconds: \$durationSeconds
        completed: \$completed
      }
    ) {
      records {
        id
        ended_at
        duration_seconds
        completed
      }
    }
  }
''';

class FocusService {
  FocusService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<FocusSession> startSession({
    required String userId,
    required String taskId,
    required String beatId,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_startSessionMutation),
        variables: {
          'userId': userId,
          'taskId': taskId,
          'beatId': beatId,
          'startedAt': DateTime.now().toUtc().toIso8601String(),
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['insertIntofocusSessionsCollection']['records'] as List)
            .first as Map<String, dynamic>;
    return FocusSession.fromJson(record);
  }

  Future<void> endSession({
    required String id,
    required int durationSeconds,
    required bool completed,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_endSessionMutation),
        variables: {
          'id': id,
          'endedAt': DateTime.now().toUtc().toIso8601String(),
          'durationSeconds': durationSeconds,
          'completed': completed,
        },
      ),
    );

    _checkErrors(result);
  }

  void _checkErrors(QueryResult result) {
    if (result.hasException) {
      final message = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ?? 'Unknown error';
      throw Exception(message);
    }
  }
}
