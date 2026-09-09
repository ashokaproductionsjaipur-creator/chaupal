import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'button_model.dart';
export 'button_model.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({
    super.key,
    this.icon,
    this.onTap,
    bool? iconPresent,
    this.iconEnd,
    bool? iconEndPresent,
    String? content,
    String? variant,
    String? size,
    bool? fullWidth,
    bool? loading,
    bool? disabled,
  })  : iconPresent = iconPresent ?? false,
        iconEndPresent = iconEndPresent ?? false,
        content = content ?? 'आगे बढ़ें (Continue)',
        variant = variant ?? 'primary',
        size = size ?? 'large',
        fullWidth = fullWidth ?? true,
        loading = loading ?? false,
        disabled = disabled ?? false;

  final Widget? icon;
  final Future<void> Function()? onTap;
  final bool iconPresent;
  final Widget? iconEnd;
  final bool iconEndPresent;
  final String content;
  final String variant;
  final String size;
  final bool fullWidth;
  final bool loading;
  final bool disabled;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  late ButtonModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _implicitTap() async {
    final text = widget.content.toLowerCase();
    if (text.contains('create new account') || text.contains('नया अकाउंट')) {
      if (mounted) context.goNamed(WorkerRegistrationWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final radius = widget.size == 'small' ? 6.0 : (widget.size == 'large' ? 12.0 : 8.0);
    final horizontal = widget.size == 'small' ? 16.0 : (widget.size == 'large' ? 32.0 : 24.0);
    final vertical = widget.size == 'small' ? 7.0 : (widget.size == 'large' ? 16.0 : 10.0);
    final isGhost = widget.variant == 'ghost';
    final isOutline = widget.variant == 'outline';
    final background = widget.variant == 'secondary'
        ? theme.secondary
        : widget.variant == 'destructive'
            ? theme.error
            : (isGhost || isOutline ? Colors.transparent : theme.primary);
    final foreground = isGhost || isOutline ? theme.primaryText : theme.onPrimary;
    final tap = widget.onTap ?? _implicitTap;

    return Opacity(
      opacity: widget.disabled ? 0.55 : 1.0,
      child: InkWell(
        onTap: widget.disabled || widget.loading ? null : tap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
            border: isOutline ? Border.all(color: theme.alternate) : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.iconPresent && widget.icon != null) widget.icon!,
                      Text(
                        widget.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelMedium.override(
                          fontWeight: FontWeight.w600,
                          color: foreground,
                          letterSpacing: 0.0,
                        ),
                      ),
                      if (widget.iconEndPresent && widget.iconEnd != null) widget.iconEnd!,
                    ].divide(const SizedBox(width: 8)),
                  ),
          ),
        ),
      ),
    );
  }
}
