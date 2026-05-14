import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/beat.dart';

const _beatFields = '''
  id
  user_id
  type
  name
  start_time
  duration_minutes
  is_active
  sort_order
''';

const _getBeatsQuery = '''
  query GetBeats {
    beatsCollection(orderBy: [{ sort_order: AscNullsLast }]) {
      edges {
        node {
          $_beatFields
        }
      }
    }
  }
''';

const _addBeatMutation = '''
  mutation AddBeat(
    \$userId: UUID!
    \$type: String!
    \$name: String!
    \$startTime: String
    \$durationMinutes: Int
    \$isActive: Boolean!
    \$sortOrder: Int!
  ) {
    insertIntoBeatsCollection(objects: [{
      user_id: \$userId
      type: \$type
      name: \$name
      start_time: \$startTime
      duration_minutes: \$durationMinutes
      is_active: \$isActive
      sort_order: \$sortOrder
    }]) {
      records {
        $_beatFields
      }
    }
  }
''';

const _toggleBeatMutation = '''
  mutation ToggleBeat(\$id: UUID!, \$isActive: Boolean!) {
    updateBeatsCollection(
      filter: { id: { eq: \$id } }
      set: { is_active: \$isActive }
    ) {
      records {
        $_beatFields
      }
    }
  }
''';

const _deleteBeatMutation = '''
  mutation DeleteBeat(\$id: UUID!) {
    deleteFromBeatsCollection(filter: { id: { eq: \$id } }) {
      records {
        id
      }
    }
  }
''';

class BeatService {
  BeatService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<List<Beat>> getBeats() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getBeatsQuery)),
    );

    _checkErrors(result);

    final edges =
        result.data!['beatsCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => Beat.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<Beat> addBeat({
    required String userId,
    required BeatType type,
    required String name,
    String? startTime,
    int? durationMinutes,
    required bool isActive,
    required int sortOrder,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_addBeatMutation),
        variables: {
          'userId': userId,
          'type': type.toJson(),
          'name': name,
          'startTime': startTime,
          'durationMinutes': durationMinutes,
          'isActive': isActive,
          'sortOrder': sortOrder,
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['insertIntoBeatsCollection']['records'] as List).first;
    return Beat.fromJson(record as Map<String, dynamic>);
  }

  Future<Beat> toggleBeat(String id, {required bool isActive}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_toggleBeatMutation),
        variables: {'id': id, 'isActive': isActive},
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['updateBeatsCollection']['records'] as List).first;
    return Beat.fromJson(record as Map<String, dynamic>);
  }

  Future<void> deleteBeat(String id) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_deleteBeatMutation),
        variables: {'id': id},
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
