import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

String _kSupabaseUrl = 'https://iaumkrgocskwhhwdwnxj.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlhdW1rcmdvY3Nrd2hod2R3bnhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4NDIwNjEsImV4cCI6MjEwNDQxODA2MX0.f1shD0zHKpSMERdurVliKvvpN9z98Rym0GifEaLxrRw';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
