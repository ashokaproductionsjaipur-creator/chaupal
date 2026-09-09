import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_label_model.dart';
export 'form_label_model.dart';

class FormLabelWidget extends StatefulWidget {
  const FormLabelWidget({
    super.key,
    String? label,
  }) : this.label = label ?? 'जॉब का नाम (Job Title)';

  final String label;

  @override
  State<FormLabelWidget> createState() => _FormLabelWidgetState();
}

class _FormLabelWidgetState extends State<FormLabelWidget> {
  late FormLabelModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormLabelModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              valueOrDefault<String>(
                widget.label,
                'जॉब का नाम (Job Title)',
              ),
              style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    lineHeight: 1.4,
                  ),
            ),
          ].divide(SizedBox(width: 4.0)),
        ),
      ),
    );
  }
}
