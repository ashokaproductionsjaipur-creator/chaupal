import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class JobHistoryArchiveWidget extends StatefulWidget {
  const JobHistoryArchiveWidget({super.key});
  static String routeName='JobHistoryArchive';
  static String routePath='/jobHistoryArchive';
  @override State<JobHistoryArchiveWidget> createState()=>_JobHistoryArchiveWidgetState();
}
class _JobHistoryArchiveWidgetState extends State<JobHistoryArchiveWidget>{
  late Future<List<Map<String,dynamic>>> future;
  @override void initState(){super.initState();future=_load();}
  Future<List<Map<String,dynamic>>> _load() async {final r=await SupaFlow.client.rpc('get_my_job_history');return List<Map<String,dynamic>>.from(r as List);}
  @override Widget build(BuildContext context){final t=FlutterFlowTheme.of(context);return Scaffold(backgroundColor:t.primaryBackground,appBar:AppBar(backgroundColor:t.primaryBackground,foregroundColor:t.primaryText,elevation:0,title:const Text('Job History | पुरानी Jobs')),body:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(context,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return const Center(child:Text('History load नहीं हो सकी.'));final rows=s.data??[];if(rows.isEmpty)return const Center(child:Text('अभी कोई Job History नहीं है.'));return RefreshIndicator(onRefresh:()async{setState(()=>future=_load());await future;},child:ListView.separated(padding:const EdgeInsets.all(16),itemCount:rows.length,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(c,i){final r=rows[i];return Card(color:t.secondaryBackground,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12),side:BorderSide(color:t.alternate)),child:ListTile(title:Text('${r['title']}',style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${r['job_date']} • ${r['start_time']}\n${r['profession_name']} • ${r['location_name']}\n₹${r['final_amount']??r['expected_amount']} • ${r['status']}'),trailing:r['final_worker_name']==null?null:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('${r['final_worker_name']}'),Text('${r['final_worker_mobile']??''}')]))); }));}));}
}
