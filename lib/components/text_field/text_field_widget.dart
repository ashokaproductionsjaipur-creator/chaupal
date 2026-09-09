import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'text_field_model.dart';
export 'text_field_model.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    String? label,
    bool? labelPresent,
    String? helper,
    bool? helperPresent,
    this.leadingIcon,
    bool? leadingIconPresent,
    this.trailingIcon,
    bool? trailingIconPresent,
    String? hint,
    String? value,
    String? onChange,
    String? onSubmit,
    String? variant,
    String? size,
    bool? error,
  })  : this.label = label ?? '',
        this.labelPresent = labelPresent ?? false,
        this.helper = helper ?? '',
        this.helperPresent = helperPresent ?? false,
        this.leadingIconPresent = leadingIconPresent ?? true,
        this.trailingIconPresent = trailingIconPresent ?? false,
        this.hint = hint ?? 'Enter username or mobile',
        this.value = value ?? '',
        this.onChange = onChange ?? '',
        this.onSubmit = onSubmit ?? '',
        this.variant = variant ?? 'outlined',
        this.size = size ?? 'medium',
        this.error = error ?? false;

  final String label;
  final bool labelPresent;
  final String helper;
  final bool helperPresent;
  final Widget? leadingIcon;
  final bool leadingIconPresent;
  final Widget? trailingIcon;
  final bool trailingIconPresent;
  final String hint;
  final String value;
  final String onChange;
  final String onSubmit;
  final String variant;
  final String size;
  final bool error;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextFieldModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextFieldModel());
    _model.inputTextController ??= TextEditingController(text: widget.value);
    _model.inputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldHeight = widget.size == 'small' ? 36.0 : (widget.size == 'large' ? 48.0 : 40.0);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.labelPresent)
            Text(
              widget.label,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
                    color: widget.error ? FlutterFlowTheme.of(context).error : FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    lineHeight: 1.4,
                  ),
            ),
          Container(
            height: fieldHeight,
            decoration: BoxDecoration(
              color: widget.variant == 'filled' ? FlutterFlowTheme.of(context).secondaryBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: widget.error ? FlutterFlowTheme.of(context).error : (widget.variant == 'ghost' ? Colors.transparent : FlutterFlowTheme.of(context).alternate),
                width: widget.variant == 'ghost' ? 0.0 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.leadingIconPresent) widget.leadingIcon!,
                  Expanded(
                    child: TextFormField(
                      controller: _model.inputTextController,
                      focusNode: _model.inputFocusNode,
                      obscureText: widget.trailingIconPresent && widget.hint.toLowerCase().contains('password'),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: widget.hint,
                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              color: FlutterFlowTheme.of(context).accent3,
                              letterSpacing: 0.0,
                              lineHeight: 1.5,
                            ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                      validator: _model.inputTextControllerValidator.asValidator(context),
                    ),
                  ),
                  if (widget.trailingIconPresent) widget.trailingIcon!,
                ],
              ),
            ),
          ),
          if (widget.helperPresent)
            Text(
              widget.helper,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: widget.error ? FlutterFlowTheme.of(context).error : FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.5,
                  ),
            ),
        ].divide(const SizedBox(height: 6.0)),
      ),
    );
  }
}
