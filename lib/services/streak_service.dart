import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/beat_completion.dart';
import '../models/streak.dart';

const _getStreakQuery = '''
  query GetStreak(\$userId: UUID!) {
    streaksCollection(
      filter: { user_id: { eq: \$userId } }
      first: 1
    ) {
      edges {
        node {
          id
          user_id
          current_streak
          longest_streak
          last_active_date
          updated_at
        }
      }
    }
  }
''';

const _updateStreakMutation = '''
  mutation UpdateStreak(
    \$userId: UUID!
    \$currentStreak: Int!
    \$longestStreak: Int!
    \$lastActiveDate: Date!
    \$updatedAt: Datetime!
  ) {
    updatestreaksCollection(
      filter: { user_id: { eq: \$userId } }
      set: {
        current_streak: \$currentStreak
        longest_streak: \$longestStreak
        last_active_date: \$lastActiveDate
        updated_at: \$updatedAt
      }
    ) {
      records {
        id
        current_streak
        longest_streak
        last_active_date
      }
    }
  }
''';

const _getCompletionsQuery = '''
  query GetBeatCompletions(\$userId: UUID!, \$fromDate: Date!) {
    beatCompletionsCollection(
      filter: {
        user_id: { eq: \$userId }
        completed_date: { gte: \$fromDate }
      }
      orderBy: [{ completed_date: AscNullsLast }]
    ) {
      edges {
        node {
          id
          beat_id
          completed_date
          tasks_total
          tasks_done
        }
      }
    }
  }
''';

const _checkBeatCompletionQuery = '''
  query CheckBeatCompletion(\$userId: UUID!, \$beatId: UUID!, \$completedDate: Date!) {
    beatCompletionsCollection(
      filter: {
        user_id: { eq: \$userId }
        beat_id: { eq: \$beatId }
        completed_date: { eq: \$completedDate }
      }
      first: 1
    ) {
      edges {
        node {
          id
        }
      }
    }
  }
''';

const _deleteBeatCompletionMutation = '''
  mutation DeleteBeatCompletion(\$userId: UUID!, \$beatId: UUID!, \$completedDate: Date!) {
    deleteFrombeatCompletionsCollection(
      filter: {
        user_id: { eq: \$userId }
        beat_id: { eq: \$beatId }
        completed_date: { eq: \$completedDate }
      }
    ) {
      records {
        id
      }
    }
  }
''';

const _recordCompletionMutation = '''
  mutation RecordBeatCompletion(
    \$userId: UUID!
    \$beatId: UUID!
    \$completedDate: Date!
    \$tasksTotal: Int!
    \$tasksDone: Int!
  ) {
    insertIntobeatCompletionsCollection(objects: [{
      user_id: \$userId
      beat_id: \$beatId
      completed_date: \$completedDate
      tasks_total: \$tasksTotal
      tasks_done: \$tasksDone
    }]) {
      records {
        id
        beat_id
        completed_date
        tasks_total
        tasks_done
      }
    }
  }
''';

class StreakService {
  StreakService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<Streak?> getStreak(String userId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getStreakQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges =
        result.data!['streaksCollection']['edges'] as List<dynamic>;
    if (edges.isEmpty) return null;
    return Streak.fromJson(edges.first['node'] as Map<String, dynamic>);
  }

  Future<void> updateStreak({
    required String userId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateStreakMutation),
        variables: {
          'userId': userId,
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'lastActiveDate': _formatDate(lastActiveDate),
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
      ),
    );

    _checkErrors(result);
  }

  Future<List<BeatCompletion>> getBeatCompletions(
    String userId,
    DateTime fromDate,
  ) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getCompletionsQuery),
        variables: {
          'userId': userId,
          'fromDate': _formatDate(fromDate),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges =
        result.data!['beatCompletionsCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => BeatCompletion.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<bool> beatCompletionExists({
    required String userId,
    required String beatId,
    required DateTime date,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_checkBeatCompletionQuery),
        variables: {
          'userId': userId,
          'beatId': beatId,
          'completedDate': _formatDate(date),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges =
        result.data!['beatCompletionsCollection']['edges'] as List<dynamic>;
    return edges.isNotEmpty;
  }

  Future<void> deleteBeatCompletion({
    required String userId,
    required String beatId,
    required DateTime date,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_deleteBeatCompletionMutation),
        variables: {
          'userId': userId,
          'beatId': beatId,
          'completedDate': _formatDate(date),
        },
      ),
    );

    _checkErrors(result);
  }

  Future<BeatCompletion> recordBeatCompletion({
    required String userId,
    required String beatId,
    required DateTime completedDate,
    required int tasksTotal,
    required int tasksDone,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_recordCompletionMutation),
        variables: {
          'userId': userId,
          'beatId': beatId,
          'completedDate': _formatDate(completedDate),
          'tasksTotal': tasksTotal,
          'tasksDone': tasksDone,
        },
      ),
    );

    _checkErrors(result);

    final record = (result.data!['insertIntobeatCompletionsCollection']
            ['records'] as List)
        .first as Map<String, dynamic>;
    return BeatCompletion.fromJson(record);
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
