import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';
import '/auth/custom_auth/custom_auth_user_provider.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';
GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();
  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();
  ChaupalAuthUser? initialUser;
  ChaupalAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;
  bool notifyOnAuthChange = true;
  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;
  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;
  void update(ChaupalAuthUser newUser) {
    final shouldUpdate = user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    if (notifyOnAuthChange && shouldUpdate) notifyListeners();
    updateNotifyOnAuthChange(true);
  }
  void stopShowingSplashImage() { showSplashImage = false; notifyListeners(); }
}

Widget _homeForUser(AppStateNotifier n) {
  final role = (n.user?.userData?.role ?? '').toLowerCase();
  if (role == 'worker') {
    final status = (n.user?.userData?.accountStatus ?? '').toLowerCase();
    return status == 'active' ? WorkerJobFeedWidget() : WorkerProfileStatusWidget();
  }
  if (role == 'owner') return OwnerDashboardWidget();
  // During registration the auth event can arrive before the authoritative
  // public.users profile is loaded. Never default that incomplete state to Owner.
  return WorkerProfileStatusWidget();
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  navigatorKey: appNavigatorKey,
  errorBuilder: (context, state) => appStateNotifier.loggedIn ? _homeForUser(appStateNotifier) : LoginScreenWidget(),
  routes: [
    FFRoute(name: '_initialize', path: '/', builder: (context, _) => appStateNotifier.loggedIn ? _homeForUser(appStateNotifier) : LoginScreenWidget()),
    FFRoute(name: RoleSelectionWidget.routeName, path: RoleSelectionWidget.routePath, builder: (context, params) => RoleSelectionWidget()),
    FFRoute(name: LoginScreenWidget.routeName, path: LoginScreenWidget.routePath, builder: (context, params) => LoginScreenWidget()),
    FFRoute(name: AdminLoginWidget.routeName, path: AdminLoginWidget.routePath, builder: (context, params) => AdminLoginWidget()),
    FFRoute(name: AdminDashboardWidget.routeName, path: AdminDashboardWidget.routePath, requireAuth: true, adminOnly: true, builder: (context, params) => AdminDashboardWidget()),
    FFRoute(name: WorkerRegistrationWidget.routeName, path: WorkerRegistrationWidget.routePath, builder: (context, params) => WorkerRegistrationWidget()),
    FFRoute(name: OwnerDashboardWidget.routeName, path: OwnerDashboardWidget.routePath, requireAuth: true, builder: (context, params) => OwnerDashboardWidget()),
    FFRoute(name: WorkerJobFeedWidget.routeName, path: WorkerJobFeedWidget.routePath, requireAuth: true, builder: (context, params) => WorkerJobFeedWidget()),
    FFRoute(name: CreateJobPostWidget.routeName, path: CreateJobPostWidget.routePath, requireAuth: true, builder: (context, params) => CreateJobPostWidget()),
    FFRoute(name: JobRequestManagementWidget.routeName, path: JobRequestManagementWidget.routePath, requireAuth: true, builder: (context, params) => JobRequestManagementWidget()),
    FFRoute(name: WorkerProfileStatusWidget.routeName, path: WorkerProfileStatusWidget.routePath, requireAuth: true, builder: (context, params) => WorkerProfileStatusWidget()),
    FFRoute(name: AdminVerificationPanelWidget.routeName, path: AdminVerificationPanelWidget.routePath, requireAuth: true, adminOnly: true, builder: (context, params) => AdminVerificationPanelWidget()),
    FFRoute(name: JobHistoryArchiveWidget.routeName, path: JobHistoryArchiveWidget.routePath, requireAuth: true, builder: (context, params) => JobHistoryArchiveWidget()),
    FFRoute(name: NotificationsWidget.routeName, path: NotificationsWidget.routePath, requireAuth: true, builder: (context, params) => NotificationsWidget()),
  ].map((r) => r.toRoute(appStateNotifier)).toList(),
);

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)));
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(String name, bool mounted, {Map<String, String> pathParameters = const <String, String>{}, Map<String, String> queryParameters = const <String, String>{}, Object? extra, bool ignoreRedirect = false}) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect) ? null : goNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  void pushNamedAuth(String name, bool mounted, {Map<String, String> pathParameters = const <String, String>{}, Map<String, String> queryParameters = const <String, String>{}, Object? extra, bool ignoreRedirect = false}) => !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect) ? null : pushNamed(name, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  void safePop() { if (canPop()) { pop(); } else { go('/'); } }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) => appState.hasRedirect() && !ignoreRedirect ? null : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) => !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) => appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap => extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}..addAll(pathParameters)..addAll(uri.queryParameters)..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey) ? extraMap[kTransitionInfoKey] as TransitionInfo : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);
  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  Map<String, dynamic> futureParamValues = {};
  bool get isEmpty => state.allParams.isEmpty || (state.allParams.length == 1 && state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) => asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(state.allParams.entries.where(isAsyncParam).map((param) async { final doc = await asyncParams[param.key]!(param.value).onError((_, __) => null); if (doc != null) { futureParamValues[param.key] = doc; return true; } return false; })).onError((_, __) => [false]).then((v) => v.every((e) => e));
  dynamic getParam<T>(String paramName, ParamType type, {bool isList = false, StructBuilder<T>? structBuilder}) {
    if (futureParamValues.containsKey(paramName)) return futureParamValues[paramName];
    if (!state.allParams.containsKey(paramName)) return null;
    final param = state.allParams[paramName];
    if (param is! String) return param;
    return deserializeParam<T>(param, type, isList, structBuilder: structBuilder);
  }
}

class FFRoute {
  const FFRoute({required this.name, required this.path, required this.builder, this.requireAuth = false, this.adminOnly = false, this.asyncParams = const {}, this.routes = const []});
  final String name;
  final String path;
  final bool requireAuth;
  final bool adminOnly;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;
  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    redirect: (context, state) async {
      if (appStateNotifier.shouldRedirect) { final redirectLocation = appStateNotifier.getRedirectLocation(); appStateNotifier.clearRedirectLocation(); return redirectLocation; }
      if (adminOnly) {
        if (!appStateNotifier.loggedIn) {
          appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
          return '/adminLogin';
        }
        try {
          final allowed = await SupaFlow.client.rpc('is_admin');
          if (allowed == true) return null;
        } catch (_) {}
        return '/adminLogin';
      }
      if (requireAuth && !appStateNotifier.loggedIn) { appStateNotifier.setRedirectLocationIfUnset(state.uri.toString()); return '/loginScreen'; }
      return null;
    },
    pageBuilder: (context, state) {
      fixStatusBarOniOS16AndBelow(context);
      final ffParams = FFParameters(state, asyncParams);
      final page = ffParams.hasFutures ? FutureBuilder(future: ffParams.completeFutures(), builder: (context, _) => builder(context, ffParams)) : builder(context, ffParams);
      final child = appStateNotifier.loading ? Center(child: SizedBox(width: 50.0, height: 50.0, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary)))) : page;
      final transitionInfo = state.transitionInfo;
      return transitionInfo.hasTransition ? CustomTransitionPage(key: state.pageKey, name: state.name, child: child, transitionDuration: transitionInfo.duration, transitionsBuilder: (context, animation, secondaryAnimation, child) => PageTransition(type: transitionInfo.transitionType, duration: transitionInfo.duration, reverseDuration: transitionInfo.duration, alignment: transitionInfo.alignment, child: child).buildTransitions(context, animation, secondaryAnimation, child)) : MaterialPage(key: state.pageKey, name: state.name, child: child);
    },
    routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({required this.hasTransition, this.transitionType = PageTransitionType.fade, this.duration = const Duration(milliseconds: 300), this.alignment});
  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;
  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;
  static bool isInactiveRootPage(BuildContext context) { final rootPageContext = context.read<RootPageContext?>(); final isRootPage = rootPageContext?.isRootPage ?? false; final location = GoRouterState.of(context).uri.toString(); return isRootPage && location != '/' && location != rootPageContext?.errorRoute; }
  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(value: RootPageContext(true, errorRoute), child: child);
}