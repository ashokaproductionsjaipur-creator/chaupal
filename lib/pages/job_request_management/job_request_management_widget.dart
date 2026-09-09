import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class JobRequestManagementWidget extends StatefulWidget {
  const JobRequestManagementWidget({super.key});
  static String routeName = 'JobRequestManagement';
  static String routePath = '/jobRequestManagement';
  @override State<JobRequestManagementWidget> createState()=>_JobRequestManagementWidgetState();
}
class _JobRequestManagementWidgetState extends State<JobRequestManagementWidget>{
  late Future<List<Map<String,dynamic>>> future;
  bool busy=false;
  @override void initState(){super.initState();future=_load();}
  Future<List<Map<String,dynamic>>> _load() async {final r=await SupaFlow.client.rpc('get_owner_requests');return List<Map<String,dynamic>>.from(r as List);}
  Future<void> _confirm(Map<String,dynamic> r) async {
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Confirm Worker | Worker तय करें'),content:Text('क्या आपने इस Worker से phone पर बात कर ली है और काम/रेट तय कर लिया है?\n\nWorker: ${r['worker_name']}\nMobile: ${r['worker_mobile']}\nOffer: ₹${r['offered_amount']}'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Yes, Confirm'))]));
    if(ok!=true||busy)return;
    setState(()=>busy=true);
    try{await SupaFlow.client.rpc('confirm_job_worker',params:{'p_job_id':r['job_id'],'p_worker_id':r['worker_id'],'p_final_amount':r['offered_amount']});if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Worker confirmed.')));setState(()=>future=_load());}}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Worker confirm नहीं हो सका. Please try again.')));}finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context){final t=FlutterFlowTheme.of(context);return Scaffold(backgroundColor:t.primaryBackground,appBar:AppBar(backgroundColor:t.primaryBackground,foregroundColor:t.primaryText,elevation:0,title:const Text('Worker Requests | Requests')),body:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(context,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return const Center(child:Text('Requests load नहीं हो सकीं.'));final rows=s.data??[];if(rows.isEmpty)return const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('अभी कोई pending Worker Request नहीं है.')));return RefreshIndicator(onRefresh:()async{setState(()=>future=_load());await future;},child:ListView.separated(padding:const EdgeInsets.all(16),itemCount:rows.length,separatorBuilder:(_,__)=>const SizedBox(height:12),itemBuilder:(c,i){final r=rows[i];return Card(color:t.secondaryBackground,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14),side:BorderSide(color:t.alternate)),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${r['worker_name']}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:5),Text('Mobile: ${r['worker_mobile']}'),const SizedBox(height:5),Text('Job: ${r['job_title']}'),Text('${r['job_date']} • ${r['start_time']}'),const SizedBox(height:5),Text('${r['worker_profession'] ?? ''} • ${r['worker_location'] ?? ''}'),const SizedBox(height:8),Text('Worker ${r['request_type']} • ₹${r['offered_amount']}'),const SizedBox(height:12),const Text('Mobile number is shown as read-only. Owner manually dials from their normal phone.',style:TextStyle(fontSize:12)),const SizedBox(height:12),SizedBox(width:double.infinity,height:48,child:FilledButton(onPressed:busy?null:()=>_confirm(r),child:const Text('Confirm Worker | Worker तय करें')))])));}));}));}
}
