import '../database.dart';

class AuthLoginAuditTable extends SupabaseTable<AuthLoginAuditRow> {
  @override
  String get tableName => 'auth_login_audit';

  @override
  AuthLoginAuditRow createRow(Map<String, dynamic> data) =>
      AuthLoginAuditRow(data);
}

class AuthLoginAuditRow extends SupabaseDataRow {
  AuthLoginAuditRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AuthLoginAuditTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get username => getField<String>('username');
  set username(String? value) => setField<String>('username', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  bool get success => getField<bool>('success')!;
  set success(bool value) => setField<bool>('success', value);

  String? get ipAddress => getField<String>('ip_address');
  set ipAddress(String? value) => setField<String>('ip_address', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
