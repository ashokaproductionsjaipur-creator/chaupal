import '/components/brand_header/brand_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/role_chip/role_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/backend/supabase/supabase.dart';
import '/backend/schema/structs/chaupal_auth_user_struct.dart';
import '/auth/custom_auth/auth_util.dart';
import '/pages/owner_dashboard/owner_dashboard_widget.dart';
import '/pages/worker_job_feed/worker_job_feed_widget.dart';
import '/pages/worker_profile_status/worker_profile_status_widget.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'login_screen_model.dart';
export 'login_screen_model.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  static String routeName = 'LoginScreen';
  static String routePath = '/loginScreen';

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _model.textFieldModel1.inputTextController?.text.trim() ?? '';
    final password = _model.textFieldModel2.inputTextController?.text ?? '';
    final selectedRole = _model.selectedRole.trim().toLowerCase();

    if (username.isEmpty || password.isEmpty) {
      showSnackbar(context, 'Username/Mobile and Password are required.');
      return;
    }
    if (selectedRole != 'owner' && selectedRole != 'worker') {
      showSnackbar(context, 'Please select Owner or Worker.');
      return;
    }

    showSnackbar(context, 'Logging in...', loading: true, duration: 30);

    try {
      final lookupResponse = await http.post(
        Uri.parse(
          'https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/chaupal-login-identity',
        ),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'role': selectedRole}),
      );

      dynamic lookupBody;
      try {
        lookupBody = jsonDecode(lookupResponse.body);
      } catch (_) {
        lookupBody = null;
      }

      if (lookupResponse.statusCode < 200 ||
          lookupResponse.statusCode >= 300 ||
          lookupBody is! Map ||
          lookupBody['login_email'] is! String) {
        final message = lookupBody is Map && lookupBody['message'] is String
            ? lookupBody['message'] as String
            : 'Invalid username/mobile or role.';
        showSnackbar(context, message);
        return;
      }

      final loginEmail = lookupBody['login_email'] as String;
      final authResponse = await SupaFlow.client.auth.signInWithPassword(
        email: loginEmail,
        password: password,
      );
      final session = authResponse.session;
      final authUser = authResponse.user;

      if (session == null || authUser == null) {
        showSnackbar(context, 'Login failed. Please check your credentials.');
        return;
      }

      final profile = await SupaFlow.client
          .from('users')
          .select('id, username, mobile_number, full_name, role, account_status')
          .eq('id', authUser.id)
          .maybeSingle();

      if (profile == null) {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'Account profile not found. Please contact support.');
        return;
      }

      final actualRole = (profile['role'] ?? '').toString().toLowerCase();
      final accountStatus =
          (profile['account_status'] ?? 'active').toString().toLowerCase();

      if (actualRole != selectedRole) {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'Selected role does not match this account.');
        return;
      }
      if (accountStatus == 'blocked') {
        await SupaFlow.client.auth.signOut();
        showSnackbar(context, 'This account is blocked. Please contact support.');
        return;
      }

      await authManager.signIn(
        authenticationToken: session.accessToken,
        refreshToken: session.refreshToken,
        tokenExpiration: session.expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
        authUid: authUser.id,
        userData: ChaupalAuthUserStruct.fromMap(profile),
      );

      if (!mounted) return;
      if (selectedRole == 'owner') {
        context.goNamed(OwnerDashboardWidget.routeName);
      } else if (accountStatus == 'active') {
        context.goNamed(WorkerJobFeedWidget.routeName);
      } else {
        context.goNamed(WorkerProfileStatusWidget.routeName);
      }
    } on AuthException catch (_) {
      showSnackbar(context, 'Invalid username/mobile or password.');
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        showSnackbar(context, 'Invalid username/mobile or password.');
      } else {
        showSnackbar(context, 'Login failed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 40.0),
                wrapWithModel(
                  model: _model.brandHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: BrandHeaderWidget(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Login | लॉगिन',
                          style: FlutterFlowTheme.of(context).titleLarge.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.4,
                              ),
                        ),
                        Text(
                          'Select your role to continue',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                lineHeight: 1.5,
                              ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.selectedRole = 'owner';
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.roleChipModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: RoleChipWidget(
                                icon: Icon(Icons.person_rounded, color: FlutterFlowTheme.of(context).primaryBackground, size: 18.0),
                                label: 'Owner | मालिक',
                                selected: _model.selectedRole == 'owner',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.selectedRole = 'worker';
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.roleChipModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: RoleChipWidget(
                                icon: Icon(Icons.engineering_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 18.0),
                                label: 'Worker | मजदूर',
                                selected: _model.selectedRole == 'worker',
                              ),
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(width: 16.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Username / Mobile', style: FlutterFlowTheme.of(context).labelLarge.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), fontWeight: FontWeight.w600, letterSpacing: 0.0, lineHeight: 1.4)),
                            wrapWithModel(
                              model: _model.textFieldModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: TextFieldWidget(
                                leadingIcon: Icon(Icons.person_outline_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 24.0),
                                leadingIconPresent: true,
                                hint: 'Enter username or mobile',
                                value: '',
                                onChange: '',
                                onSubmit: '',
                                variant: 'outlined',
                                error: false,
                              ),
                            ),
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password', style: FlutterFlowTheme.of(context).labelLarge.override(font: GoogleFonts.inter(fontWeight: FontWeight.w600), fontWeight: FontWeight.w600, letterSpacing: 0.0, lineHeight: 1.4)),
                            wrapWithModel(
                              model: _model.textFieldModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: TextFieldWidget(
                                leadingIcon: Icon(Icons.lock_outline_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 24.0),
                                leadingIconPresent: true,
                                trailingIcon: Icon(Icons.visibility_off_rounded, color: FlutterFlowTheme.of(context).primaryText, size: 24.0),
                                trailingIconPresent: true,
                                hint: 'Enter password',
                                value: '',
                                onChange: '',
                                onSubmit: '',
                                variant: 'outlined',
                                size: 'medium',
                                error: false,
                              ),
                            ),
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.buttonModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: ButtonWidget(
                            iconPresent: false,
                            iconEndPresent: false,
                            content: 'Login | लॉगिन करें',
                            onTap: _login,
                            variant: 'primary',
                            size: 'large',
                            fullWidth: true,
                            loading: false,
                            disabled: false,
                          ),
                        ),
                        Container(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: wrapWithModel(
                            model: _model.buttonModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonWidget(
                              iconPresent: false,
                              iconEndPresent: false,
                              content: 'Forgot Password? Contact Support',
                              variant: 'ghost',
                              size: 'small',
                              fullWidth: false,
                              loading: false,
                              disabled: false,
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                  ].divide(const SizedBox(height: 24.0)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(height: 16.0, thickness: 1.0, color: FlutterFlowTheme.of(context).alternate)),
                    Text('OR', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(), color: FlutterFlowTheme.of(context).onSurface, letterSpacing: 0.0, lineHeight: 1.4)),
                    Expanded(child: Divider(height: 16.0, thickness: 1.0, color: FlutterFlowTheme.of(context).alternate)),
                  ].divide(const SizedBox(width: 16.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('New to Chaupal?', style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(), color: FlutterFlowTheme.of(context).secondaryText, letterSpacing: 0.0, lineHeight: 1.5)),
                    wrapWithModel(
                      model: _model.buttonModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: ButtonWidget(
                        iconPresent: false,
                        iconEndPresent: false,
                        content: 'Create New Account | नया अकाउंट बनाएं',
                        variant: 'outline',
                        size: 'large',
                        fullWidth: true,
                        loading: false,
                        disabled: false,
                      ),
                    ),
                  ].divide(const SizedBox(height: 16.0)),
                ),
                Container(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                  child: Text('v1.0.0 • Secure Production Environment', style: FlutterFlowTheme.of(context).labelSmall.override(font: GoogleFonts.inter(), color: FlutterFlowTheme.of(context).onSurface, letterSpacing: 0.0, lineHeight: 1.4)),
                ),
              ].divide(const SizedBox(height: 32.0)),
            ),
          ),
        ),
      ),
    );
  }
}
