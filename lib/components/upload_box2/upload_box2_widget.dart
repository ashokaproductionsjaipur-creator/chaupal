import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_box2_model.dart';
export 'upload_box2_model.dart';

class UploadBox2Widget extends StatefulWidget {
  const UploadBox2Widget({
    super.key,
    this.icon,
    String? text,
  }) : this.text = text ?? 'फोटो लेने के लिए यहाँ क्लिक करें';

  final Widget? icon;
  final String text;

  @override
  State<UploadBox2Widget> createState() => _UploadBox2WidgetState();
}

class _UploadBox2WidgetState extends State<UploadBox2Widget> {
  late UploadBox2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UploadBox2Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.icon!,
          Text(
            valueOrDefault<String>(
              widget.text,
              'फोटो लेने के लिए यहाँ क्लिक करें',
            ),
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  lineHeight: 1.5,
                ),
          ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
