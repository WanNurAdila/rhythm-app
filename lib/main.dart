import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'navigation/app_router.dart';
import 'repositories/auth_repository.dart';

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
      title: 'Rhythm App',
      routerConfig: router,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF8B7CF6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CF6),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B7CF6)),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B7CF6),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8B7CF6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF171513),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171513),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      ),
    );
  }
}
