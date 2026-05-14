import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

const _profileFields = '''
  id
  display_name
  created_at
''';

const _getProfileQuery = '''
  query GetProfile(\$id: UUID!) {
    profilesCollection(filter: { id: { eq: \$id } }) {
      edges {
        node {
          $_profileFields
        }
      }
    }
  }
''';

const _updateProfileMutation = '''
  mutation UpdateProfile(\$id: UUID!, \$displayName: String!) {
    updateProfilesCollection(
      filter: { id: { eq: \$id } }
      set: { display_name: \$displayName }
    ) {
      records {
        $_profileFields
      }
    }
  }
''';

class ProfileService {
  ProfileService({required GraphQLClient client}) : _client = client;

  final GraphQLClient _client;

  Future<Profile> getProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final result = await _client.query(
      QueryOptions(
        document: gql(_getProfileQuery),
        variables: {'id': user.id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _checkErrors(result);

    final edges =
        result.data!['profilesCollection']['edges'] as List<dynamic>;
    if (edges.isEmpty) throw Exception('Profile not found.');

    return Profile.fromJson(
      edges.first['node'] as Map<String, dynamic>,
      email: user.email ?? '',
    );
  }

  Future<Profile> updateProfile({required String displayName}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateProfileMutation),
        variables: {'id': user.id, 'displayName': displayName},
      ),
    );

    _checkErrors(result);

    final records =
        result.data!['updateProfilesCollection']['records'] as List<dynamic>;
    if (records.isEmpty) throw Exception('Profile update failed.');

    return Profile.fromJson(
      records.first as Map<String, dynamic>,
      email: user.email ?? '',
    );
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
