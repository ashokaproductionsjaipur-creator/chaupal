import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'brand_header_model.dart';
export 'brand_header_model.dart';

class BrandHeaderWidget extends StatefulWidget {
  const BrandHeaderWidget({super.key});

  @override
  State<BrandHeaderWidget> createState() => _BrandHeaderWidgetState();
}

class _BrandHeaderWidgetState extends State<BrandHeaderWidget> {
  late BrandHeaderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BrandHeaderModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryText,
            borderRadius: BorderRadius.circular(20.0),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Text(
            'C',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 40.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w900,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  lineHeight: 1.5,
                ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'चौपाल | CHAUPAL',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w800,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    lineHeight: 1.3,
                  ),
            ),
            Text(
              'Construction & Daily Wage Marketplace',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).labelMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).labelMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    lineHeight: 1.4,
                  ),
            ),
          ].divide(SizedBox(height: 4.0)),
        ),
      ].divide(SizedBox(height: 24.0)),
    );
  }
}
