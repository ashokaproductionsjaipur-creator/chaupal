import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/backend/schema/structs/index.dart';
import 'custom_auth_user_provider.dart';

export 'custom_auth_manager.dart';

const _kAuthTokenKey = '_auth_authentication_token_';
const _kRefreshTokenKey = '_auth_refresh_token_';
const _kTokenExpirationKey = '_auth_token_expiration_';
const _kUidKey = '_auth_uid_';
const _kUserDataKey = '_auth_user_data_';
// Set while a sign out is in effect. Its presence makes any session values
// that survived the sign out unusable, so a failed cleanup cannot resurrect
// them on the next launch.
const _kSignedOutKey = '_auth_signed_out_';
const _kLegacyMigrationDoneKey = '_auth_legacy_migration_complete_';

class CustomAuthManager {
  // Auth session attributes
  String? authenticationToken;
  String? refreshToken;
  DateTime? tokenExpiration;
  // User attributes
  String? uid;
  ChaupalAuthUserStruct? userData;

  Future signOut() async {
    // Record the sign out before changing anything else. Once this marker is
    // stored, initialize() refuses to restore the session on the next launch,
    // so the sign out cannot be undone even if clearing the stored values
    // below fails. If the marker cannot be stored we have not touched the
    // in-memory session or the user stream yet, so nothing is left
    // half-signed-out: the caller is simply told the sign out did not happen.
    final markError = await _recordSignedOut();
    if (markError != null) {
      throw StateError(
        'Sign out could not be recorded, so you are still signed in: $markError',
      );
    }

    authenticationToken = null;
    refreshToken = null;
    tokenExpiration = null;
    uid = null;
    userData = null;
    // Update the current user.
    chaupalAuthUserSubject.add(
      ChaupalAuthUser(loggedIn: false),
    );
    // Clearing the stored values is best effort from here: the marker has
    // already made the session unusable, so a failure only leaves inert data
    // behind for the next launch to clean up.
    await _clearPersistedSession();
  }

  Future<ChaupalAuthUser?> signIn({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
    ChaupalAuthUserStruct? userData,
  }) async =>
      await _updateCurrentUser(
        authenticationToken: authenticationToken,
        refreshToken: refreshToken,
        tokenExpiration: tokenExpiration,
        authUid: authUid,
        userData: userData,
      );

  Future<void> updateAuthUserData({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
    ChaupalAuthUserStruct? userData,
  }) async {
    assert(
      currentUser?.loggedIn ?? false,
      'User must be logged in to update auth user data.',
    );

    await _updateCurrentUser(
      authenticationToken: authenticationToken,
      refreshToken: refreshToken,
      tokenExpiration: tokenExpiration,
      authUid: authUid,
      userData: userData,
    );
  }

  Future<ChaupalAuthUser?> _updateCurrentUser({
    String? authenticationToken,
    String? refreshToken,
    DateTime? tokenExpiration,
    String? authUid,
    ChaupalAuthUserStruct? userData,
  }) async {
    this.authenticationToken = authenticationToken;
    this.refreshToken = refreshToken;
    this.tokenExpiration = tokenExpiration;
    this.uid = authUid;
    this.userData = userData;
    // Update the current user stream.
    final updatedUser = ChaupalAuthUser(
      loggedIn: true,
      uid: authUid,
      userData: userData,
    );
    chaupalAuthUserSubject.add(updatedUser);
    await persistAuthData();
    return updatedUser;
  }

  // Left at the default options deliberately. encryptedSharedPreferences is
  // deprecated and always on in this version, and resetOnError is currently
  // accepted by the Dart API but never read by the Android implementation, so
  // setting it would suggest a recovery from Keystore corruption that does not
  // actually happen. If the Keystore is corrupt, reads fail, initialize()
  // treats the user as signed out, and signing out reports a real error rather
  // than pretending to have succeeded.
  final _secureStorage = const FlutterSecureStorage();

  Future initialize() async {
    try {
      await _migrateLegacyPersistedAuthData();

      if (await _secureStorage.read(key: _kSignedOutKey) != null) {
        // A previous sign out was recorded but may not have finished clearing
        // the stored session. Restore nothing, and retry the cleanup, which
        // removes the marker once it succeeds.
        await _clearPersistedSession();
        chaupalAuthUserSubject.add(
          ChaupalAuthUser(loggedIn: false),
        );
        return;
      }

      authenticationToken = await _secureStorage.read(key: _kAuthTokenKey);
      refreshToken = await _secureStorage.read(key: _kRefreshTokenKey);
      final tokenExpirationStr =
          await _secureStorage.read(key: _kTokenExpirationKey);
      tokenExpiration = tokenExpirationStr != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(tokenExpirationStr))
          : null;
      uid = await _secureStorage.read(key: _kUidKey);
      final userDataStr = await _secureStorage.read(key: _kUserDataKey);
      userData = userDataStr != null
          ? ChaupalAuthUserStruct.fromSerializableMap(
              (jsonDecode(userDataStr) as Map).cast<String, dynamic>(),
            )
          : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
      return;
    }

    final authTokenExists = authenticationToken != null;
    final tokenExpired =
        tokenExpiration != null && tokenExpiration!.isBefore(DateTime.now());
    final updatedUser = ChaupalAuthUser(
      loggedIn: authTokenExists && !tokenExpired,
      uid: uid,
      userData: userData,
    );
    chaupalAuthUserSubject.add(updatedUser);
  }

  // Migrates auth session data that was previously persisted in plaintext
  // (before secure persistence was enabled) into secure storage, then removes
  // the plaintext copy.
  //
  // A marker in secure storage records that this finished, so the usual case
  // -- an app that has already migrated, or never had legacy data -- costs one
  // read on startup instead of opening SharedPreferences and issuing a removal
  // per key on every cold start. The marker is only written once every legacy
  // key is confirmed gone, so a removal that fails is retried next launch.
  Future<void> _migrateLegacyPersistedAuthData() async {
    if (await _secureStorage.read(key: _kLegacyMigrationDoneKey) != null) {
      return;
    }
    final legacyPrefs = await SharedPreferences.getInstance();
    // A sign out recorded while the app used plaintext persistence still
    // applies. Its cleanup may not have finished, so session values can still
    // be sitting in preferences; importing them would undo that sign out.
    final legacySignedOut = legacyPrefs.getBool(_kSignedOutKey) ?? false;
    // Whatever secure storage already holds is newer than any plaintext
    // leftovers, so import only when there is no secure session to clobber.
    // Without this, a legacy value whose removal failed could be re-imported
    // on a later launch and overwrite the session the user actually has.
    final hasSecureSession =
        await _secureStorage.read(key: _kAuthTokenKey) != null;
    final importLegacySession = !legacySignedOut && !hasSecureSession;

    var removedEveryLegacyKey = true;
    Future<void> migrateKey(String key, String? legacyValue) async {
      if (legacyValue != null && importLegacySession) {
        await _secureStorage.write(key: key, value: legacyValue);
      }
      // remove() returns false rather than throwing when it does not stick,
      // and the in-memory cache is cleared either way, so the returned flag is
      // the only way to know the plaintext copy is really gone.
      if (legacyPrefs.containsKey(key) && !await legacyPrefs.remove(key)) {
        removedEveryLegacyKey = false;
      }
    }

    await migrateKey(_kAuthTokenKey, legacyPrefs.getString(_kAuthTokenKey));
    await migrateKey(
        _kRefreshTokenKey, legacyPrefs.getString(_kRefreshTokenKey));
    await migrateKey(
      _kTokenExpirationKey,
      legacyPrefs.getInt(_kTokenExpirationKey)?.toString(),
    );
    await migrateKey(_kUidKey, legacyPrefs.getString(_kUidKey));
    await migrateKey(_kUserDataKey, legacyPrefs.getString(_kUserDataKey));

    // The plaintext sign-out marker goes last, and only once every session
    // value is confirmed gone: while any of them survives, the marker has to
    // survive with them so a retried migration still refuses to import them.
    if (removedEveryLegacyKey &&
        legacyPrefs.containsKey(_kSignedOutKey) &&
        !await legacyPrefs.remove(_kSignedOutKey)) {
      removedEveryLegacyKey = false;
    }

    if (removedEveryLegacyKey) {
      await _secureStorage.write(key: _kLegacyMigrationDoneKey, value: 'true');
    }
  }

  /// Serializes persistence so that overlapping auth transitions -- a sign-out
  /// landing while a sign-in is still writing, for example -- cannot interleave
  /// their storage operations. Each transition's writes complete, in call
  /// order, before the next transition's begin.
  Future<void> _persistQueue = Future.value();

  /// Runs [task] after any persistence already in flight, returning the error
  /// it failed with, or null if it succeeded.
  ///
  /// This never completes with an error itself, so one failed transition
  /// cannot poison the queue for later ones; callers decide how to react.
  /// Signing in treats a failure as non-fatal -- the session is live in memory
  /// either way, and letting the error escape would abort the action flow that
  /// triggered it. Signing out treats a failure as terminal, because a session
  /// left behind on disk would be read back as valid on the next launch.
  Future<Object?> _enqueuePersistTask(Future<void> Function() task) {
    final pending = _persistQueue.then<Object?>((_) async {
      try {
        await task();
        return null;
      } catch (e) {
        if (kDebugMode) {
          print('Error persisting auth data: $e');
        }
        return e;
      }
    });
    _persistQueue = pending;
    return pending;
  }

  /// Deletes [key], confirming it is actually gone before returning, and
  /// retrying a bounded number of times if it is not.
  ///
  /// Used for the credentials: one that outlives its own deletion would be
  /// read back as a valid session on the next launch, so a delete that fails
  /// -- or that reports success while leaving the value in place -- has to
  /// become a visible error rather than a silent one.
  Future<void> _deleteVerified(String key) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        // Back off briefly; a retry that fires immediately tends to hit the
        // same transient condition. Only ever reached on the failure path.
        await Future.delayed(Duration(milliseconds: 50 * attempt));
      }
      try {
        await _secureStorage.delete(key: key);
        if (await _secureStorage.read(key: key) == null) {
          return;
        }
        lastError = StateError('$key is still present after being deleted.');
      } catch (e) {
        lastError = e;
      }
    }
    throw StateError('Could not delete $key from secure storage: $lastError');
  }

  /// Records that the user has signed out. While this marker is stored,
  /// initialize() will not restore a session, whatever else is still stored.
  ///
  /// The write is read back: everything about sign out hinges on this value
  /// being durable, so a write that silently does not stick has to be caught
  /// here rather than discovered on the next launch.
  Future<Object?> _recordSignedOut() => _enqueuePersistTask(() async {
        Object? lastError;
        for (var attempt = 0; attempt < 3; attempt++) {
          if (attempt > 0) {
            await Future.delayed(Duration(milliseconds: 50 * attempt));
          }
          try {
            await _secureStorage.write(key: _kSignedOutKey, value: 'true');
            if (await _secureStorage.read(key: _kSignedOutKey) != null) {
              return;
            }
            lastError = StateError('The signed out marker did not persist.');
          } catch (e) {
            lastError = e;
          }
        }
        throw StateError('Could not record the sign out: $lastError');
      });

  /// Deletes every stored session value, then the signed-out marker. The
  /// marker goes last, so if any deletion fails the marker survives and the
  /// next launch retries instead of restoring a half-cleared session.
  Future<Object?> _clearPersistedSession() => _enqueuePersistTask(() async {
        await _deleteVerified(_kAuthTokenKey);
        await _deleteVerified(_kRefreshTokenKey);
        await _secureStorage.delete(key: _kTokenExpirationKey);
        await _secureStorage.delete(key: _kUidKey);
        await _secureStorage.delete(key: _kUserDataKey);
        await _secureStorage.delete(key: _kSignedOutKey);
      });

  // Serializing these writes also avoids a Web-specific hazard: the first
  // write lazily creates the shared encryption key backing secure storage,
  // and concurrent first writes can each create a different key, leaving
  // most fields undecryptable after reload.
  Future<Object?> persistAuthData() {
    // Snapshot the session synchronously, before the first await, so that a
    // transition landing while this write waits its turn in the queue cannot
    // tear the values it persists. These locals shadow the fields of the same
    // name, so the write below cannot read the mutable state by accident.
    final authenticationToken = this.authenticationToken;
    final refreshToken = this.refreshToken;
    final tokenExpiration = this.tokenExpiration;
    final uid = this.uid;
    final userData = this.userData;

    return _enqueuePersistTask(() async {
      // The auth token goes first: it is what initialize() reads to decide
      // whether a session exists, so clearing it first means an interrupted
      // sign out still reads as signed out.
      authenticationToken != null
          ? await _secureStorage.write(
              key: _kAuthTokenKey, value: authenticationToken)
          : await _deleteVerified(_kAuthTokenKey);
      refreshToken != null
          ? await _secureStorage.write(
              key: _kRefreshTokenKey, value: refreshToken)
          : await _deleteVerified(_kRefreshTokenKey);
      tokenExpiration != null
          ? await _secureStorage.write(
              key: _kTokenExpirationKey,
              value: tokenExpiration.millisecondsSinceEpoch.toString(),
            )
          : await _secureStorage.delete(key: _kTokenExpirationKey);
      uid != null
          ? await _secureStorage.write(key: _kUidKey, value: uid)
          : await _secureStorage.delete(key: _kUidKey);
      userData != null
          ? await _secureStorage.write(
              key: _kUserDataKey,
              value: jsonEncode(userData.toSerializableMap()))
          : await _secureStorage.delete(key: _kUserDataKey);

      if (authenticationToken != null) {
        // Signing back in supersedes any recorded sign out. Deleted through
        // the verifying path, not a bare delete(): a marker that outlived its
        // own deletion would sign this brand new session straight back out on
        // the next launch. Deleted last, so the session only becomes
        // restorable once all of it has been stored.
        //
        // The cleanup in _clearPersistedSession() does not need this. There, a
        // marker that survives keeps the veto in place and the next launch
        // retries, which is the safe direction; here a surviving marker would
        // block a session the user legitimately has.
        await _deleteVerified(_kSignedOutKey);
      }
    });
  }
}

ChaupalAuthUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
