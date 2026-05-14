import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/beat_completion.dart';
import '../models/streak.dart';

const _streakFields = '''
  id
  user_id
  current_streak
  longest_streak
  last_active_date
''';

const _completionFields = '''
  id
  user_id
  beat_id
  completed_date
  tasks_total
  tasks_done
''';

const _getStreakQuery = '''
  query GetStreak(\$userId: UUID!) {
    streaksCollection(filter: { user_id: { eq: \$userId } }) {
      edges {
        node {
          $_streakFields
        }
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
          $_completionFields
        }
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
    insertIntoBeatCompletionsCollection(objects: [{
      user_id: \$userId
      beat_id: \$beatId
      completed_date: \$completedDate
      tasks_total: \$tasksTotal
      tasks_done: \$tasksDone
    }]) {
      records {
        $_completionFields
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
  ) {
    updateStreaksCollection(
      filter: { user_id: { eq: \$userId } }
      set: {
        current_streak: \$currentStreak
        longest_streak: \$longestStreak
        last_active_date: \$lastActiveDate
      }
    ) {
      records {
        $_streakFields
      }
    }
  }
''';

const _insertStreakMutation = '''
  mutation InsertStreak(
    \$userId: UUID!
    \$currentStreak: Int!
    \$longestStreak: Int!
    \$lastActiveDate: Date!
  ) {
    insertIntoStreaksCollection(objects: [{
      user_id: \$userId
      current_streak: \$currentStreak
      longest_streak: \$longestStreak
      last_active_date: \$lastActiveDate
    }]) {
      records {
        $_streakFields
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

    final record = (result.data!['insertIntoBeatCompletionsCollection']
            ['records'] as List)
        .first as Map<String, dynamic>;
    return BeatCompletion.fromJson(record);
  }

  // Tries update first; inserts if the user has no streak row yet.
  Future<Streak> upsertStreak({
    required String userId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
  }) async {
    final variables = {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': _formatDate(lastActiveDate),
    };

    final updateResult = await _client.mutate(
      MutationOptions(
        document: gql(_updateStreakMutation),
        variables: variables,
      ),
    );
    _checkErrors(updateResult);

    final updated = updateResult.data!['updateStreaksCollection']['records']
        as List<dynamic>;

    if (updated.isNotEmpty) {
      return Streak.fromJson(updated.first as Map<String, dynamic>);
    }

    // No existing row — insert.
    final insertResult = await _client.mutate(
      MutationOptions(
        document: gql(_insertStreakMutation),
        variables: variables,
      ),
    );
    _checkErrors(insertResult);

    final inserted = (insertResult.data!['insertIntoStreaksCollection']
            ['records'] as List)
        .first as Map<String, dynamic>;
    return Streak.fromJson(inserted);
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
