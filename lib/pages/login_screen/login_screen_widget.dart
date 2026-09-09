import '/components/brand_header/brand_header_widget.dart';
import '/components/button/button_widget.dart';
import '/components/role_chip/role_chip_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/backend/supabase/supabase.dart';
import '/backend/schema/structs/chaupal_auth_user_struct.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/owner_dashboard/owner_dashboard_widget.dart';
import '/pages/worker_job_feed/worker_job_feed_widget.dart';
import '/pages/worker_profile_status/worker_profile_status_widget.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'login_screen_model.dart';
export 'login_screen_model.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});
  static String routeName = 'LoginScreen';
  static String routePath = '/loginScreen';
  @override State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginScreenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override void initState(){super.initState();_model=createModel(context,()=>LoginScreenModel());}
  @override void dispose(){_model.dispose();super.dispose();}

  Future<void> _login() async {
    final username=_model.textFieldModel1.inputTextController?.text.trim()??'';
    final password=_model.textFieldModel2.inputTextController?.text??'';
    final selectedRole=_model.selectedRole.trim().toLowerCase();
    if(username.isEmpty||password.isEmpty){showSnackbar(context,'Username/Mobile and Password are required.');return;}
    if(selectedRole!='owner'&&selectedRole!='worker'){showSnackbar(context,'Please select Owner or Worker.');return;}
    showSnackbar(context,'Logging in...',loading:true,duration:30);
    try{
      final r=await http.post(Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/chaupal-login-identity'),headers:const {'Content-Type':'application/json'},body:jsonEncode({'username':username,'role':selectedRole}));
      dynamic body;try{body=jsonDecode(r.body);}catch(_){body=null;}
      if(r.statusCode<200||r.statusCode>=300||body is! Map||body['login_email'] is! String){final m=body is Map&&body['message'] is String?body['message'] as String:'Invalid username/mobile or role.';showSnackbar(context,m);return;}
      final authResponse=await SupaFlow.client.auth.signInWithPassword(email:body['login_email'] as String,password:password);
      final session=authResponse.session;final authUser=authResponse.user;
      if(session==null||authUser==null){showSnackbar(context,'Login failed. Please check your credentials.');return;}
      final profile=await SupaFlow.client.from('users').select('id, username, mobile_number, full_name, role, account_status').eq('id',authUser.id).maybeSingle();
      if(profile==null){await SupaFlow.client.auth.signOut();showSnackbar(context,'Account profile not found. Please contact support.');return;}
      final actualRole=(profile['role']??'').toString().toLowerCase();final accountStatus=(profile['account_status']??'active').toString().toLowerCase();
      if(actualRole!=selectedRole){await SupaFlow.client.auth.signOut();showSnackbar(context,'Selected role does not match this account.');return;}
      if(accountStatus=='blocked'){await SupaFlow.client.auth.signOut();showSnackbar(context,'This account is blocked. Please contact support.');return;}
      await authManager.signIn(authenticationToken:session.accessToken,refreshToken:session.refreshToken,tokenExpiration:session.expiresAt==null?null:DateTime.fromMillisecondsSinceEpoch(session.expiresAt!*1000),authUid:authUser.id,userData:ChaupalAuthUserStruct.fromMap(profile));
      if(!mounted)return;
      if(selectedRole=='owner'){context.goNamed(OwnerDashboardWidget.routeName);}else if(accountStatus=='active'){context.goNamed(WorkerJobFeedWidget.routeName);}else{context.goNamed(WorkerProfileStatusWidget.routeName);}
    }on AuthException catch(_){showSnackbar(context,'Invalid username/mobile or password.');}catch(e){showSnackbar(context,e.toString().contains('Invalid login credentials')?'Invalid username/mobile or password.':'Login failed. Please try again.');}
  }

  @override Widget build(BuildContext context){
    return GestureDetector(
      onTap:(){FocusScope.of(context).unfocus();FocusManager.instance.primaryFocus?.unfocus();},
      child:Scaffold(key:scaffoldKey,backgroundColor:FlutterFlowTheme.of(context).primaryBackground,body:Padding(padding:const EdgeInsets.all(24),child:SingleChildScrollView(primary:false,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const SizedBox(height:40),
        wrapWithModel(model:_model.brandHeaderModel,updateCallback:()=>safeSetState((){}),child:BrandHeaderWidget()),
        const SizedBox(height:24),
        Text('Login | लॉगिन',textAlign:TextAlign.center,style:FlutterFlowTheme.of(context).titleLarge.override(font:GoogleFonts.inter(fontWeight:FontWeight.bold),fontWeight:FontWeight.bold,letterSpacing:0.0)),
        const SizedBox(height:8),
        Text('Select your role to continue',textAlign:TextAlign.center,style:FlutterFlowTheme.of(context).bodyMedium.override(font:GoogleFonts.inter(),color:FlutterFlowTheme.of(context).secondaryText,letterSpacing:0.0)),
        const SizedBox(height:24),
        Row(children:[Expanded(child:InkWell(onTap:(){_model.selectedRole='owner';safeSetState((){});},child:wrapWithModel(model:_model.roleChipModel1,updateCallback:()=>safeSetState((){}),child:RoleChipWidget(icon:Icon(Icons.person_rounded,color:FlutterFlowTheme.of(context).primaryBackground,size:18),label:'Owner | मालिक',selected:_model.selectedRole=='owner')))),const SizedBox(width:16),Expanded(child:InkWell(onTap:(){_model.selectedRole='worker';safeSetState((){});},child:wrapWithModel(model:_model.roleChipModel2,updateCallback:()=>safeSetState((){}),child:RoleChipWidget(icon:Icon(Icons.engineering_rounded,color:FlutterFlowTheme.of(context).secondaryText,size:18),label:'Worker | मजदूर',selected:_model.selectedRole=='worker'))))]),
        const SizedBox(height:24),
        Text('Username / Mobile',style:FlutterFlowTheme.of(context).labelLarge.override(font:GoogleFonts.inter(fontWeight:FontWeight.w600),fontWeight:FontWeight.w600,letterSpacing:0.0)),
        const SizedBox(height:4),
        wrapWithModel(model:_model.textFieldModel1,updateCallback:()=>safeSetState((){}),child:TextFieldWidget(leadingIcon:Icon(Icons.person_outline_rounded,color:FlutterFlowTheme.of(context).primaryText,size:24),leadingIconPresent:true,hint:'Enter username or mobile',value:'',onChange:'',onSubmit:'',variant:'outlined',error:false)),
        const SizedBox(height:16),
        Text('Password',style:FlutterFlowTheme.of(context).labelLarge.override(font:GoogleFonts.inter(fontWeight:FontWeight.w600),fontWeight:FontWeight.w600,letterSpacing:0.0)),
        const SizedBox(height:4),
        wrapWithModel(model:_model.textFieldModel2,updateCallback:()=>safeSetState((){}),child:TextFieldWidget(leadingIcon:Icon(Icons.lock_outline_rounded,color:FlutterFlowTheme.of(context).primaryText,size:24),leadingIconPresent:true,trailingIcon:Icon(Icons.visibility_off_rounded,color:FlutterFlowTheme.of(context).primaryText,size:24),trailingIconPresent:true,hint:'Enter password',value:'',onChange:'',onSubmit:'',variant:'outlined',size:'medium',error:false)),
        const SizedBox(height:24),
        wrapWithModel(model:_model.buttonModel1,updateCallback:()=>safeSetState((){}),child:ButtonWidget(content:'Login | लॉगिन करें',onTap:_login,variant:'primary',size:'large',fullWidth:true,loading:false,disabled:false)),
        const SizedBox(height:12),
        Center(child:wrapWithModel(model:_model.buttonModel2,updateCallback:()=>safeSetState((){}),child:ButtonWidget(content:'Forgot Password? Contact Support',variant:'ghost',size:'small',fullWidth:false,loading:false,disabled:false))),
        const SizedBox(height:24),
        Row(children:[Expanded(child:Divider(color:FlutterFlowTheme.of(context).alternate)),const Padding(padding:EdgeInsets.symmetric(horizontal:16),child:Text('OR')),Expanded(child:Divider(color:FlutterFlowTheme.of(context).alternate))]),
        const SizedBox(height:24),
        Text('New to Chaupal?',textAlign:TextAlign.center,style:FlutterFlowTheme.of(context).bodyMedium.override(font:GoogleFonts.inter(),color:FlutterFlowTheme.of(context).secondaryText,letterSpacing:0.0)),
        const SizedBox(height:12),
        wrapWithModel(model:_model.buttonModel3,updateCallback:()=>safeSetState((){}),child:ButtonWidget(content:'Create New Account | नया अकाउंट बनाएं',variant:'outline',size:'large',fullWidth:true,loading:false,disabled:false)),
        const SizedBox(height:32),
        Text('v1.0.0 • Secure Production Environment',textAlign:TextAlign.center,style:FlutterFlowTheme.of(context).labelSmall.override(font:GoogleFonts.inter(),color:FlutterFlowTheme.of(context).onSurface,letterSpacing:0.0)),
      ]))))
    );
  }
}
