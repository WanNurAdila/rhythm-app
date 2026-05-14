import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'navigation/app_router.dart';
import 'repositories/auth_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  final graphqlUrl = dotenv.env['GRAPHQL_URL'];

  if (supabaseUrl == null || supabaseAnonKey == null || graphqlUrl == null) {
    throw Exception(
      'SUPABASE_URL, SUPABASE_ANON_KEY, and GRAPHQL_URL must be set in .env file',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final httpLink = HttpLink(
    graphqlUrl,
    defaultHeaders: {'apikey': supabaseAnonKey},
  );

  final authLink = AuthLink(
    getToken: () {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken ?? supabaseAnonKey;
      return 'Bearer $token';
    },
  );

  final graphQLClient = GraphQLClient(
    cache: GraphQLCache(),
    link: authLink.concat(httpLink),
  );

  runApp(
    GraphQLProvider(client: ValueNotifier(graphQLClient), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(authRepository: AuthRepository()).router;

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Rhythm',
        routerConfig: router,
        theme: buildAppTheme(),
      ),
    );
  }
}
