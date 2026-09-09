// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChaupalAuthUserStruct extends BaseStruct {
  ChaupalAuthUserStruct({
    String? id,
    String? username,
    String? mobileNumber,
    String? fullName,
    String? role,
    String? accountStatus,
  })  : _id = id,
        _username = username,
        _mobileNumber = mobileNumber,
        _fullName = fullName,
        _role = role,
        _accountStatus = accountStatus;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "username" field.
  String? _username;
  String get username => _username ?? '';
  set username(String? val) => _username = val;

  bool hasUsername() => _username != null;

  // "mobile_number" field.
  String? _mobileNumber;
  String get mobileNumber => _mobileNumber ?? '';
  set mobileNumber(String? val) => _mobileNumber = val;

  bool hasMobileNumber() => _mobileNumber != null;

  // "full_name" field.
  String? _fullName;
  String get fullName => _fullName ?? '';
  set fullName(String? val) => _fullName = val;

  bool hasFullName() => _fullName != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  set role(String? val) => _role = val;

  bool hasRole() => _role != null;

  // "account_status" field.
  String? _accountStatus;
  String get accountStatus => _accountStatus ?? '';
  set accountStatus(String? val) => _accountStatus = val;

  bool hasAccountStatus() => _accountStatus != null;

  static ChaupalAuthUserStruct fromMap(Map<String, dynamic> data) =>
      ChaupalAuthUserStruct(
        id: data['id'] as String?,
        username: data['username'] as String?,
        mobileNumber: data['mobile_number'] as String?,
        fullName: data['full_name'] as String?,
        role: data['role'] as String?,
        accountStatus: data['account_status'] as String?,
      );

  static ChaupalAuthUserStruct? maybeFromMap(dynamic data) => data is Map
      ? ChaupalAuthUserStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'username': _username,
        'mobile_number': _mobileNumber,
        'full_name': _fullName,
        'role': _role,
        'account_status': _accountStatus,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'username': serializeParam(
          _username,
          ParamType.String,
        ),
        'mobile_number': serializeParam(
          _mobileNumber,
          ParamType.String,
        ),
        'full_name': serializeParam(
          _fullName,
          ParamType.String,
        ),
        'role': serializeParam(
          _role,
          ParamType.String,
        ),
        'account_status': serializeParam(
          _accountStatus,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChaupalAuthUserStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChaupalAuthUserStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        username: deserializeParam(
          data['username'],
          ParamType.String,
          false,
        ),
        mobileNumber: deserializeParam(
          data['mobile_number'],
          ParamType.String,
          false,
        ),
        fullName: deserializeParam(
          data['full_name'],
          ParamType.String,
          false,
        ),
        role: deserializeParam(
          data['role'],
          ParamType.String,
          false,
        ),
        accountStatus: deserializeParam(
          data['account_status'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChaupalAuthUserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChaupalAuthUserStruct &&
        id == other.id &&
        username == other.username &&
        mobileNumber == other.mobileNumber &&
        fullName == other.fullName &&
        role == other.role &&
        accountStatus == other.accountStatus;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, username, mobileNumber, fullName, role, accountStatus]);
}

ChaupalAuthUserStruct createChaupalAuthUserStruct({
  String? id,
  String? username,
  String? mobileNumber,
  String? fullName,
  String? role,
  String? accountStatus,
}) =>
    ChaupalAuthUserStruct(
      id: id,
      username: username,
      mobileNumber: mobileNumber,
      fullName: fullName,
      role: role,
      accountStatus: accountStatus,
    );
