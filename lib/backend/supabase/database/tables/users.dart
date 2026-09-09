import '../database.dart';

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get username => getField<String>('username')!;
  set username(String value) => setField<String>('username', value);

  String get mobileNumber => getField<String>('mobile_number')!;
  set mobileNumber(String value) => setField<String>('mobile_number', value);

  String get fullName => getField<String>('full_name')!;
  set fullName(String value) => setField<String>('full_name', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String? get accountStatus => getField<String>('account_status');
  set accountStatus(String? value) => setField<String>('account_status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
