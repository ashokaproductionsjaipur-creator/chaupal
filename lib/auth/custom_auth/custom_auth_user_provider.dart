import 'package:rxdart/rxdart.dart';

import '/backend/schema/structs/index.dart';
import 'custom_auth_manager.dart';

class ChaupalAuthUser {
  ChaupalAuthUser({
    required this.loggedIn,
    this.uid,
    this.userData,
  });

  bool loggedIn;
  String? uid;
  ChaupalAuthUserStruct? userData;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<ChaupalAuthUser> chaupalAuthUserSubject =
    BehaviorSubject.seeded(ChaupalAuthUser(loggedIn: false));
Stream<ChaupalAuthUser> chaupalAuthUserStream() => chaupalAuthUserSubject
    .asBroadcastStream()
    .map((user) => currentUser = user);
