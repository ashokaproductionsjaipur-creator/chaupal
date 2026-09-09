import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/role_selection/role_selection_widget.dart';
import '/pages/worker_job_feed/worker_job_feed_widget.dart';
import 'package:flutter/material.dart';

class WorkerProfileStatusWidget extends StatefulWidget {
  const WorkerProfileStatusWidget({super.key});
  static String routeName='WorkerProfileStatus';
  static String routePath='/workerProfileStatus';
  @override State<WorkerProfileStatusWidget> createState()=>_WorkerProfileStatusWidgetState();
}
class _WorkerProfileStatusWidgetState extends State<WorkerProfileStatusWidget>{
  late Future<Map<String,dynamic>> future;
  @override void initState(){super.initState();future=_load();}
  Future<Map<String,dynamic>> _load() async {final r=await SupaFlow.client.rpc('get_my_worker_status');return Map<String,dynamic>.from(r as Map);}
  Future<void> _logout() async {await authManager.signOut();if(mounted)context.goNamed(RoleSelectionWidget.routeName);}
  void _profile(){showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Profile | प्रोफाइल'),content:Text('${currentUserData?.fullName??'Worker'}\n${currentUserData?.username??''}\n${currentUserData?.mobileNumber??''}'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Close'))]));}
  @override Widget build(BuildContext context){final t=FlutterFlowTheme.of(context);return Scaffold(backgroundColor:t.primaryBackground,appBar:AppBar(backgroundColor:t.primaryBackground,foregroundColor:t.primaryText,elevation:0,titleSpacing:0,leading:IconButton(tooltip:'Back',icon:const Icon(Icons.arrow_back_rounded),onPressed:()=>context.pop()),title:const Text('Worker Profile | कामगार'),actions:[IconButton(tooltip:'Profile',onPressed:_profile,icon:const Icon(Icons.account_circle_outlined)),IconButton(tooltip:'Logout',onPressed:_logout,icon:const Icon(Icons.logout_rounded)),const SizedBox(width:8)]),body:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return const Center(child:Text('Profile load नहीं हो सका.'));final d=s.data??{};final u=Map<String,dynamic>.from((d['user'] as Map?)??{});final w=Map<String,dynamic>.from((d['worker'] as Map?)??{});final p=Map<String,dynamic>.from((d['profession'] as Map?)??{});final l=Map<String,dynamic>.from((d['location'] as Map?)??{});final status='${w['verification_status']??'pending'}'.toLowerCase();final approved=status=='approved';return ListView(padding:const EdgeInsets.all(16),children:[Card(color:t.secondaryBackground,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:BorderSide(color:t.alternate)),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[_ProfileAvatar(path:u['profile_photo']?.toString(),radius:34),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${u['full_name']??''}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text('${u['mobile_number']??''}'),Text('${p['display_name']??w['other_profession']??''} • ${l['display_name']??''}')]))]))),const SizedBox(height:14),Card(color:t.secondaryBackground,elevation:0,child:Padding(padding:const EdgeInsets.all(18),child:Text('Verification: ${status.toUpperCase()}',style:const TextStyle(fontWeight:FontWeight.w700)))),const SizedBox(height:14),Card(color:t.secondaryBackground,elevation:0,child:Padding(padding:const EdgeInsets.all(18),child:Text(approved?'आपका Worker Account verified है। अब आप matching Jobs देख और Request भेज सकते हैं.':status=='rejected'?'आपका verification reject हुआ है। Support से संपर्क करें.':'आपका Account अभी Verification में है। Approval मिलने के बाद आप Job देख और Accept कर सकेंगे.'))),if(approved)...[const SizedBox(height:16),SizedBox(height:50,child:FilledButton(onPressed:()=>context.goNamed(WorkerJobFeedWidget.routeName),child:const Text('View Matching Jobs | Jobs देखें')))]]);});}
}
class _ProfileAvatar extends StatelessWidget{const _ProfileAvatar({required this.path,required this.radius});final String? path;final double radius;@override Widget build(BuildContext context){if(path==null||path!.isEmpty)return CircleAvatar(radius:radius,child:const Icon(Icons.person,size:34));final url=SupaFlow.client.storage.from('profile-media').getPublicUrl(path!);return CircleAvatar(radius:radius,backgroundImage:NetworkImage(url));}}
