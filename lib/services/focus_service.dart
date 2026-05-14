import 'package:graphql_flutter/graphql_flutter.dart';

const _startSessionMutation = '''
  mutation StartFocusSession(
    \$userId: UUID!
    \$taskId: UUID!
    \$beat: String!
    \$startedAt: Datetime!
  ) {
    insertIntoFocusSessionsCollection(objects: [{
      user_id: \$userId
      task_id: \$taskId
      beat: \$beat
      started_at: \$startedAt
    }]) {
      records {
        id
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
    updateFocusSessionsCollection(
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

  Future<String> startSession({
    required String userId,
    required String taskId,
    required String beat,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_startSessionMutation),
        variables: {
          'userId': userId,
          'taskId': taskId,
          'beat': beat,
          'startedAt': DateTime.now().toUtc().toIso8601String(),
        },
      ),
    );

    _checkErrors(result);

    final record = (result.data!['insertIntoFocusSessionsCollection']['records']
        as List)
        .first as Map<String, dynamic>;
    return record['id'] as String;
  }

  Future<void> endSession({
    required String sessionId,
    required int durationSeconds,
    required bool completed,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_endSessionMutation),
        variables: {
          'id': sessionId,
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
