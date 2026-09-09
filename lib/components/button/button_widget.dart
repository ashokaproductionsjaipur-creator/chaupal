import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'button_model.dart';
export 'button_model.dart';

class ButtonWidget extends StatefulWidget {
  const ButtonWidget({super.key,this.icon,this.onTap,bool? iconPresent,this.iconEnd,bool? iconEndPresent,String? content,String? variant,String? size,bool? fullWidth,bool? loading,bool? disabled}) : iconPresent=iconPresent??false,iconEndPresent=iconEndPresent??false,content=content??'आगे बढ़ें (Continue)',variant=variant??'primary',size=size??'large',fullWidth=fullWidth??true,loading=loading??false,disabled=disabled??false;
  final Widget? icon; final Future<void> Function()? onTap; final bool iconPresent; final Widget? iconEnd; final bool iconEndPresent; final String content; final String variant; final String size; final bool fullWidth; final bool loading; final bool disabled;
  @override State<ButtonWidget> createState()=>_ButtonWidgetState();
}
class _ButtonWidgetState extends State<ButtonWidget>{
  late ButtonModel _model;
  @override void setState(VoidCallback callback){super.setState(callback);_model.onUpdate();}
  @override void initState(){super.initState();_model=createModel(context,()=>ButtonModel());}
  @override void dispose(){_model.maybeDispose();super.dispose();}
  Future<void> _implicitTap() async {
    final c=widget.content.toLowerCase();
    if(c.contains('create new account')||c.contains('नया अकाउंट')){if(mounted)context.goNamed(WorkerRegistrationWidget.routeName);}
  }
  @override Widget build(BuildContext context){
    final tap=widget.onTap??_implicitTap;
    return Opacity(opacity:valueOrDefault<double>(valueOrDefault<bool>(widget.disabled,false)?0.55:1.0,1.0),child:InkWell(onTap:widget.disabled||widget.loading?null:tap,borderRadius:BorderRadius.circular(widget.size=='small'?4.0:(widget.size=='large'?12.0:8.0)),child:Container(decoration:BoxDecoration(color:valueOrDefault<Color>(() {if(widget.variant=='secondary')return FlutterFlowTheme.of(context).secondary;if(widget.variant=='outline'||widget.variant=='ghost')return Colors.transparent;if(widget.variant=='destructive')return FlutterFlowTheme.of(context).error;return FlutterFlowTheme.of(context).primary;}(),FlutterFlowTheme.of(context).primary),borderRadius:BorderRadius.circular(widget.size=='small'?4.0:(widget.size=='large'?12.0:8.0)),border:Border.all(color:widget.variant=='outline'?FlutterFlowTheme.of(context).alternate:Colors.transparent,width:widget.variant=='outline'?1.0:0.0)),child:Stack(alignment:AlignmentDirectional(0.0,0.0),children:[Opacity(opacity:widget.loading?0.0:1.0,child:Padding(padding:EdgeInsetsDirectional.fromSTEB(widget.size=='small'?16.0:(widget.size=='large'?32.0:24.0),widget.size=='small'?4.0:(widget.size=='large'?16.0:8.0),widget.size=='small'?16.0:(widget.size=='large'?32.0:24.0),widget.size=='small'?4.0:(widget.size=='large'?16.0:8.0)),child:Row(mainAxisSize:MainAxisSize.min,children:[if(widget.iconPresent)widget.icon!,Text(widget.content,maxLines:1,overflow:TextOverflow.clip,style:FlutterFlowTheme.of(context).labelMedium.override(font:GoogleFonts.inter(fontWeight:FlutterFlowTheme.of(context).labelMedium.fontWeight),color:widget.variant=='outline'?FlutterFlowTheme.of(context).primaryText:(widget.variant=='ghost'?FlutterFlowTheme.of(context).primary:FlutterFlowTheme.of(context).onPrimary),letterSpacing:0.0,lineHeight:1.4)),if(widget.iconEndPresent)widget.iconEnd!].divide(SizedBox(width:8.0)))),if(widget.loading)CircularPercentIndicator(percent:0.0,radius:7.0,lineWidth:2.0,animation:true,animateFromLastPercent:true,progressColor:FlutterFlowTheme.of(context).onPrimary,backgroundColor:FlutterFlowTheme.of(context).alternate)]))));
  }
}
