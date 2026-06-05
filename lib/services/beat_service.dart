import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/beat.dart';

const _beatFields = '''
  id
  user_id
  type
  name
  color
  start_time
  end_time
  is_active
  is_preset
  sort_order
  created_at
''';

const _getBeatsQuery =
    '''
  query GetBeats(\$userId: UUID!) {
    beatsCollection(
      filter: { user_id: { eq: \$userId } }
      orderBy: [{ sort_order: AscNullsLast }]
    ) {
      edges {
        node {
          $_beatFields
        }
      }
    }
  }
''';

const _getActiveBeatsQuery = '''
  query GetActiveBeats(\$userId: UUID!) {
    beatsCollection(
      filter: {
        user_id: { eq: \$userId }
        is_active: { eq: true }
      }
      orderBy: [{ sort_order: AscNullsLast }]
    ) {
      edges {
        node {
          id
          user_id
          type
          name
          start_time
          duration_minutes
          is_active
          sort_order
        }
      }
    }
  }
''';

const _addCustomBeatMutation = '''
  mutation AddCustomBeat(
    \$userId:        UUID!
    \$name:          String!
    \$color:         String!
    \$startTime:     Time!
    \$endTime:       Time!
    \$sortOrder:     Int!
  ) {
    insertIntobeatsCollection(objects: [{
      user_id:        \$userId
      type:           "custom"
      name:           \$name
      color:          \$color
      start_time:     \$startTime
      end_time:       \$endTime
      is_active:      true
      is_preset:      false
      sort_order:     \$sortOrder
    }]) {
      records {
        id
        user_id
        type
        name
        color
        start_time
        end_time
        is_active
        is_preset
        sort_order
        created_at
      }
    }
  }
''';

const _toggleBeatMutation = '''
  mutation ToggleBeat(\$id: UUID!, \$isActive: Boolean!) {
    updatebeatsCollection(
      filter: { id: { eq: \$id } }
      set: { is_active: \$isActive }
    ) {
      records {
        id
        is_active
      }
    }
  }
''';

const _updateBeatMutation = '''
  mutation UpdateBeat(
    \$id:            UUID!
    \$name:          String!
    \$color:         String!
    \$startTime:     Time!
    \$endTime:       Time!
    \$isActive:      Boolean!
  ) {
    updatebeatsCollection(
      filter: {
        id:        { eq: \$id }
        is_preset: { eq: false }
      }
      set: {
        name:           \$name
        color:          \$color
        start_time:     \$startTime
        end_time:       \$endTime
        is_active:      \$isActive
      }
    ) {
      records {
        id user_id type name color
        start_time end_time
        is_active
        is_preset sort_order
      }
    }
  }
''';

const _activatePresetBeatMutation = '''
  mutation ActivatePresetBeat(
    \$userId:    UUID!
    \$type:      String!
    \$name:      String!
    \$startTime: Time!
    \$endTime:   Time!
    \$sortOrder: Int!
  ) {
    insertIntobeatsCollection(objects: [{
      user_id:    \$userId
      type:       \$type
      name:       \$name
      start_time: \$startTime
      end_time:   \$endTime
      is_active:  true
      is_preset:  true
      sort_order: \$sortOrder
    }]) {
      records { id }
    }
  }
''';

const _deleteBeatMutation = '''
  mutation DeleteBeat(\$id: UUID!) {
    deleteFrombeatsCollection(
      filter: { id: { eq: \$id } }
      atMost: 1
    ) {
      records {
        id
      }
    }
  }
''';

class BeatService {
  BeatService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<List<Beat>> getBeats({required String userId}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getBeatsQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges = result.data!['beatsCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => Beat.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<List<Beat>> getActiveBeats({required String userId}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getActiveBeatsQuery),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges = result.data!['beatsCollection']['edges'] as List<dynamic>;
    return edges
        .map((e) => Beat.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  Future<Beat> addCustomBeat({
    required String userId,
    required String name,
    required String color,
    required String startTime,
    required String endTime,
    required int sortOrder,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_addCustomBeatMutation),
        variables: {
          'userId': userId,
          'name': name,
          'color': color,
          'startTime': startTime,
          'endTime': endTime,
          'sortOrder': sortOrder,
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['insertIntobeatsCollection']['records'] as List).first;
    return Beat.fromJson(record as Map<String, dynamic>);
  }

  Future<void> activatePresetBeat({
    required String userId,
    required String type,
    required String name,
    required String startTime,
    required String endTime,
    required int sortOrder,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_activatePresetBeatMutation),
        variables: {
          'userId': userId,
          'type': type,
          'name': name,
          'startTime': startTime,
          'endTime': endTime,
          'sortOrder': sortOrder,
        },
      ),
    );
    _checkErrors(result);
  }

  Future<void> toggleBeat(String id, {required bool isActive}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_toggleBeatMutation),
        variables: {'id': id, 'isActive': isActive},
      ),
    );

    _checkErrors(result);
  }

  Future<Beat> updateBeat({
    required String id,
    required String name,
    required String color,
    required String startTime,
    required String endTime,
    required bool isActive,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateBeatMutation),
        variables: {
          'id': id,
          'name': name,
          'color': color,
          'startTime': startTime,
          'endTime': endTime,
          'isActive': isActive,
        },
      ),
    );

    _checkErrors(result);

    final record =
        (result.data!['updatebeatsCollection']['records'] as List).first;
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
