import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
export '../models/profile.dart' show Gender, AmbientSoundType;

const _getProfileQuery = r'''
  query GetProfile($id: UUID!) {
    profilesCollection(
      filter: { id: { eq: $id } }
      first: 1
    ) {
      edges {
        node {
          id
          display_name
          email
          gender
          pronouns
          timezone
          ambient_sound
          created_at
          updated_at
        }
      }
    }
  }
''';

const _updateProfile = r'''
  mutation UpdateProfile(
    $id:           UUID!
    $displayName:  String!
    $email:        String
    $gender:       opaque
    $pronouns:     String
    $timezone:     String
    $ambientSound: opaque
  ) {
    updateprofilesCollection(
      filter: { id: { eq: $id } }
      set: {
        display_name:  $displayName
        email:         $email
        gender:        $gender
        pronouns:      $pronouns
        timezone:      $timezone
        ambient_sound: $ambientSound
      }
    ) {
      records {
        id
        display_name
        email
        gender
        pronouns
        timezone
        ambient_sound
        created_at
        updated_at
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
    );
  }

  Future<Profile> updateProfile({
    required String displayName,
    Gender? gender,
    String? pronouns,
    String? timezone,
    AmbientSoundType? ambientSound,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated.');

    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateProfile),
        variables: {
          'id': user.id,
          'displayName': displayName,
          'email': user.email,
          'gender': gender?.name,
          'pronouns': pronouns,
          'timezone': timezone,
          'ambientSound': ambientSound?.name,
        },
      ),
    );

    _checkErrors(result);

    final records =
        result.data!['updateprofilesCollection']['records'] as List<dynamic>;
    if (records.isEmpty) throw Exception('Profile update failed.');

    return Profile.fromJson(records.first as Map<String, dynamic>);
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
