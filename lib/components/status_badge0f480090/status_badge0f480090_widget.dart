import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'status_badge0f480090_model.dart';
export 'status_badge0f480090_model.dart';

class StatusBadge0f480090Widget extends StatefulWidget {
  const StatusBadge0f480090Widget({
    super.key,
    Color? bg,
    Color? borderColor,
    this.icon,
    String? label,
    Color? textColor,
  })  : this.bg = bg ?? const Color(0x00000000),
        this.borderColor = borderColor ?? const Color(0x00000000),
        this.label = label ?? 'VERIFIED WORKER',
        this.textColor = textColor ?? const Color(0x00000000);

  final Color bg;
  final Color borderColor;
  final Widget? icon;
  final String label;
  final Color textColor;

  @override
  State<StatusBadge0f480090Widget> createState() =>
      _StatusBadge0f480090WidgetState();
}

class _StatusBadge0f480090WidgetState extends State<StatusBadge0f480090Widget> {
  late StatusBadge0f480090Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatusBadge0f480090Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget.bg,
          FlutterFlowTheme.of(context).success10,
        ),
        borderRadius: BorderRadius.circular(9999.0),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.icon!,
              Text(
                valueOrDefault<String>(
                  widget.label,
                  'VERIFIED WORKER',
                ),
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: valueOrDefault<Color>(
                        widget.textColor,
                        FlutterFlowTheme.of(context).success,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      lineHeight: 1.4,
                    ),
              ),
            ].divide(SizedBox(width: 4.0)),
          ),
        ),
      ),
    );
  }
}
