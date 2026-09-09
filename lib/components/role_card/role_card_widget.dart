import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_card_model.dart';
export 'role_card_model.dart';

class RoleCardWidget extends StatefulWidget {
  const RoleCardWidget({
    super.key,
    this.icon,
    String? subtitle,
    String? title,
    bool? selected,
  })  : this.subtitle =
            subtitle ?? 'मैं काम डालना चाहता हूँ (I want to post a job)',
        this.title = title ?? 'मालिक (Owner)',
        this.selected = selected ?? false;

  final Widget? icon;
  final String subtitle;
  final String title;
  final bool selected;

  @override
  State<RoleCardWidget> createState() => _RoleCardWidgetState();
}

class _RoleCardWidgetState extends State<RoleCardWidget> {
  late RoleCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RoleCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: valueOrDefault<Color>(
                  valueOrDefault<bool>(
                    widget.selected,
                    false,
                  )
                      ? FlutterFlowTheme.of(context).primaryText
                      : FlutterFlowTheme.of(context).alternate,
                  FlutterFlowTheme.of(context).alternate,
                ),
                width: valueOrDefault<double>(
                  valueOrDefault<bool>(
                    widget.selected,
                    false,
                  )
                      ? 2.0
                      : 2.0,
                  2.0,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: valueOrDefault<Color>(
                            valueOrDefault<bool>(
                              widget.selected,
                              false,
                            )
                                ? FlutterFlowTheme.of(context).primaryText
                                : FlutterFlowTheme.of(context).alternate,
                            FlutterFlowTheme.of(context).alternate,
                          ),
                          width: valueOrDefault<double>(
                            valueOrDefault<bool>(
                              widget.selected,
                              false,
                            )
                                ? 1.0
                                : 1.0,
                            1.0,
                          ),
                        ),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: widget.icon!,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            widget.title,
                            'मालिक (Owner)',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            widget.subtitle,
                            'मैं काम डालना चाहता हूँ (I want to post a job)',
                          ),
                          textAlign: TextAlign.center,
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
                      ].divide(SizedBox(height: 4.0)),
                    ),
                    if (valueOrDefault<bool>(
                      widget.selected,
                      false,
                    ))
                      Container(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                  ].divide(SizedBox(height: 16.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
