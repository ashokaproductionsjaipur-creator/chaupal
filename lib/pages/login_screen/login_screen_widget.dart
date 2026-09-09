import '/components/brand_header/brand_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/role_chip/role_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          padding: EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            primary: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 40.0,
                ),
                wrapWithModel(
                  model: _model.brandHeaderModel,
                  updateCallback: () => safeSetState(() {}),
                  child: BrandHeaderWidget(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Login | लॉगिन',
                          style:
                              FlutterFlowTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                        ),
                        Text(
                          'Select your role to continue',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
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
                                icon: Icon(
                                  Icons.person_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  size: 18.0,
                                ),
                                label: 'Owner | मालिक',
                                selected: true,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
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
                                icon: Icon(
                                  Icons.engineering_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 18.0,
                                ),
                                label: 'Worker | मजदूर',
                                selected: false,
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(width: 16.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username / Mobile',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            wrapWithModel(
                              model: _model.textFieldModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: TextFieldWidget(
                                label: '',
                                labelPresent: false,
                                helper: '',
                                helperPresent: false,
                                leadingIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                leadingIconPresent: true,
                                trailingIconPresent: false,
                                hint: 'Enter username or mobile',
                                value: '',
                                onChange: '',
                                onSubmit: '',
                                variant: 'outlined',
                                error: false,
                              ),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            wrapWithModel(
                              model: _model.textFieldModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: TextFieldWidget(
                                label: '',
                                labelPresent: false,
                                helper: '',
                                helperPresent: false,
                                leadingIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                leadingIconPresent: true,
                                trailingIcon: Icon(
                                  Icons.visibility_off_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                trailingIconPresent: true,
                                hint: 'Enter password',
                                value: '',
                                onChange: '',
                                onSubmit: '',
                                variant: 'outlined',
                                error: false,
                              ),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.buttonModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: ButtonWidget(
                            iconPresent: false,
                            iconEndPresent: false,
                            content: 'Login | लॉगिन करें',
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
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ].divide(SizedBox(height: 24.0)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Divider(
                        height: 16.0,
                        thickness: 1.0,
                        indent: 0.0,
                        endIndent: 0.0,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    Text(
                      'OR',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).onSurface,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Divider(
                        height: 16.0,
                        thickness: 1.0,
                        indent: 0.0,
                        endIndent: 0.0,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                  ].divide(SizedBox(width: 16.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'New to Chaupal?',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.5,
                          ),
                    ),
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
                  ].divide(SizedBox(height: 16.0)),
                ),
                Container(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                    child: Container(
                      child: Container(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'v1.0.0 • Secure Production Environment',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).onSurface,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 32.0)),
            ),
          ),
        ),
      ),
    );
  }
}
