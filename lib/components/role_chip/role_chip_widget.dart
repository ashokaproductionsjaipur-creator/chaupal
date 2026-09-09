import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_chip_model.dart';
export 'role_chip_model.dart';

class RoleChipWidget extends StatefulWidget {
  const RoleChipWidget({
    super.key,
    this.icon,
    String? label,
    bool? selected,
  })  : this.label = label ?? 'Owner | मालिक',
        this.selected = selected ?? true;

  final Widget? icon;
  final String label;
  final bool selected;

  @override
  State<RoleChipWidget> createState() => _RoleChipWidgetState();
}

class _RoleChipWidgetState extends State<RoleChipWidget> {
  late RoleChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RoleChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          valueOrDefault<bool>(
            widget.selected,
            true,
          )
              ? FlutterFlowTheme.of(context).primaryText
              : Colors.transparent,
          FlutterFlowTheme.of(context).primaryText,
        ),
        borderRadius: BorderRadius.circular(4.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: valueOrDefault<Color>(
            valueOrDefault<bool>(
              widget.selected,
              true,
            )
                ? FlutterFlowTheme.of(context).primaryText
                : FlutterFlowTheme.of(context).alternate,
            FlutterFlowTheme.of(context).primaryText,
          ),
          width: valueOrDefault<double>(
            valueOrDefault<bool>(
              widget.selected,
              true,
            )
                ? 1.0
                : 1.0,
            1.0,
          ),
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.icon!,
          Text(
            valueOrDefault<String>(
              widget.label,
              'Owner | मालिक',
            ),
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<bool>(
                      widget.selected,
                      true,
                    )
                        ? FlutterFlowTheme.of(context).primaryBackground
                        : FlutterFlowTheme.of(context).secondaryText,
                    FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.4,
                ),
          ),
        ].divide(SizedBox(width: 8.0)),
      ),
    );
  }
}
