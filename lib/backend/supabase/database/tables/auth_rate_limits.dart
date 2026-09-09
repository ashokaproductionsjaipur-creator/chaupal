import '../database.dart';

class AuthRateLimitsTable extends SupabaseTable<AuthRateLimitsRow> {
  @override
  String get tableName => 'auth_rate_limits';

  @override
  AuthRateLimitsRow createRow(Map<String, dynamic> data) =>
      AuthRateLimitsRow(data);
}

class AuthRateLimitsRow extends SupabaseDataRow {
  AuthRateLimitsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AuthRateLimitsTable();

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  DateTime get windowStartedAt => getField<DateTime>('window_started_at')!;
  set windowStartedAt(DateTime value) =>
      setField<DateTime>('window_started_at', value);

  int? get attemptCount => getField<int>('attempt_count');
  set attemptCount(int? value) => setField<int>('attempt_count', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
