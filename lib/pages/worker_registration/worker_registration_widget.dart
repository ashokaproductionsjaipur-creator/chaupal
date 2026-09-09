import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '/backend/supabase/supabase.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/schema/structs/chaupal_auth_user_struct.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/index.dart';

class WorkerRegistrationWidget extends StatefulWidget {
  const WorkerRegistrationWidget({super.key});
  static String routeName = 'WorkerRegistration';
  static String routePath = '/workerRegistration';
  @override State<WorkerRegistrationWidget> createState() => _WorkerRegistrationWidgetState();
}

class _WorkerRegistrationWidgetState extends State<WorkerRegistrationWidget> {
  final name=TextEditingController(),mobile=TextEditingController(),username=TextEditingController(),password=TextEditingController(),confirm=TextEditingController(),aadhaar=TextEditingController(),otherProfession=TextEditingController();
  final picker=ImagePicker();
  String role='owner';
  int? locationId,professionId;
  List<Map<String,dynamic>> locations=[],professions=[];
  XFile? profilePhoto,aadhaarPhoto,livePhoto;
  bool busy=false,loadingMasters=true;

  @override void initState(){super.initState();_loadMasters();}
  @override void dispose(){for(final c in [name,mobile,username,password,confirm,aadhaar,otherProfession])c.dispose();super.dispose();}

  Future<void> _loadMasters() async {
    if(mounted)setState(()=>loadingMasters=true);
    try {
      final r=await http.get(Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/chaupal-masters'));
      final body=jsonDecode(r.body);
      if(r.statusCode<200||r.statusCode>=300||body is! Map||body['ok']!=true) throw Exception(body is Map&&body['message'] is String?body['message']:'Master data could not be loaded.');
      final rawLocations=body['locations'];
      final rawProfessions=body['professions'];
      if(mounted){setState(() {locations=List<Map<String,dynamic>>.from(rawLocations is List?rawLocations:const []);professions=List<Map<String,dynamic>>.from(rawProfessions is List?rawProfessions:const []);});}
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Dropdown data load failed: ${e.toString().replaceFirst('Exception: ','')}')));
    } finally { if(mounted)setState(()=>loadingMasters=false); }
  }

  Future<XFile?> _image({required bool cameraOnly}) async {
    final source=cameraOnly?ImageSource.camera:await showModalBottomSheet<ImageSource>(context:context,builder:(c)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[ListTile(title:const Text('Camera'),leading:const Icon(Icons.camera_alt_outlined),onTap:()=>Navigator.pop(c,ImageSource.camera)),ListTile(title:const Text('Gallery'),leading:const Icon(Icons.photo_library_outlined),onTap:()=>Navigator.pop(c,ImageSource.gallery))])));
    if(source==null)return null;
    return picker.pickImage(source:source,imageQuality:80,maxWidth:1600);
  }

  Future<void> _register() async {
    if(busy)return;
    final u=username.text.trim().toLowerCase(),m=mobile.text.trim(),p=password.text;
    if(name.text.trim().isEmpty||!RegExp(r'^\d{10}$').hasMatch(m)||u.length<3||p.length<8||p!=confirm.text||locationId==null||profilePhoto==null||aadhaar.text.trim().length!=12||aadhaarPhoto==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Required fields सही भरें और सभी जरूरी photos चुनें. Password कम से कम 8 characters होना चाहिए.')));return;}
    if(role=='worker'&&professionId==null&&otherProfession.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Profession चुनें.')));return;}
    if(role=='worker'&&livePhoto==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Worker verification के लिए Live Verification Photo जरूरी है.')));return;}
    setState(()=>busy=true);
    try {
      final response=await http.post(Uri.parse('https://iaumkrgocskwhhwdwnxj.supabase.co/functions/v1/username-auth'),headers:const {'Content-Type':'application/json'},body:jsonEncode({'action':'signup','username':u,'password':p,'role':role,'full_name':name.text.trim(),'mobile_number':m}));
      dynamic body;try{body=jsonDecode(response.body);}catch(_){body=null;}
      if(response.statusCode<200||response.statusCode>=300||body is! Map||body['ok']!=true){
        final code=body is Map&&body['code'] is String?body['code']: 'http_${response.statusCode}';
        final message=body is Map&&body['message'] is String?body['message']:'Account could not be created.';
        throw Exception('$code: $message');
      }
      final access=body['access_token']?.toString(),refresh=body['refresh_token']?.toString(),uid=body['user_id']?.toString();
      if(access==null||refresh==null||uid==null)throw Exception('Registration session could not be created.');
      await SupaFlow.client.auth.setSession(refresh);
      final expires=body['expires_at'] is num?DateTime.fromMillisecondsSinceEpoch((body['expires_at'] as num).toInt()*1000):DateTime.now().add(Duration(seconds:(body['expires_in']??3600)as int));
      final userMap=Map<String,dynamic>.from(body['user'] as Map);
      await authManager.signIn(authenticationToken:access,refreshToken:refresh,tokenExpiration:expires,authUid:uid,userData:ChaupalAuthUserStruct.fromMap(userMap));
      final stamp=DateTime.now().millisecondsSinceEpoch;
      final profilePath='$uid/profile_$stamp.jpg',aadhaarPath='$uid/aadhaar_$stamp.jpg';
      await SupaFlow.client.storage.from('profile-media').uploadBinary(profilePath,await profilePhoto!.readAsBytes(),fileOptions:const FileOptions(contentType:'image/jpeg',upsert:false));
      await SupaFlow.client.storage.from('aadhaar-private').uploadBinary(aadhaarPath,await aadhaarPhoto!.readAsBytes(),fileOptions:const FileOptions(contentType:'image/jpeg',upsert:false));
      String? livePath;
      if(role=='worker'){livePath='$uid/live_$stamp.jpg';await SupaFlow.client.storage.from('worker-verification').uploadBinary(livePath,await livePhoto!.readAsBytes(),fileOptions:const FileOptions(contentType:'image/jpeg',upsert:false));}
      final result=await SupaFlow.client.rpc('complete_registration',params:{'p_full_name':name.text.trim(),'p_mobile_number':m,'p_username':u,'p_role':role,'p_chaupal_location_id':locationId,'p_profession_id':professionId,'p_other_profession':otherProfession.text.trim(),'p_aadhaar_number':aadhaar.text.trim(),'p_aadhaar_photo':aadhaarPath,'p_profile_photo':profilePath,'p_live_verification_photo':livePath});
      final profile=Map<String,dynamic>.from(result as Map);
      await authManager.updateAuthUserData(authenticationToken:access,refreshToken:refresh,tokenExpiration:expires,authUid:uid,userData:ChaupalAuthUserStruct.fromMap(profile));
      if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(role=='worker'?'Account created. Verification pending.':'Account created successfully.')));if(role=='worker')context.goNamed(WorkerProfileStatusWidget.routeName);else context.goNamed(OwnerDashboardWidget.routeName);}
    } catch(e) {
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Registration failed: ${e.toString().replaceFirst('Exception: ','')}')));
    } finally {if(mounted)setState(()=>busy=false);}
  }

  @override Widget build(BuildContext context){
    final t=FlutterFlowTheme.of(context);
    return Scaffold(backgroundColor:t.primaryBackground,appBar:AppBar(backgroundColor:t.primaryBackground,foregroundColor:t.primaryText,elevation:0,title:const Text('Create Account | अकाउंट बनाएं')),body:ListView(padding:const EdgeInsets.all(16),children:[
      Row(children:[Expanded(child:ChoiceChip(label:const Text('Owner | मालिक'),selected:role=='owner',onSelected:(_){setState(()=>role='owner');})),const SizedBox(width:10),Expanded(child:ChoiceChip(label:const Text('Worker | कामगार'),selected:role=='worker',onSelected:(_){setState(()=>role='worker');}))]),
      const SizedBox(height:14),_field('Full Name | पूरा नाम',name,'अपना नाम'),const SizedBox(height:12),_field('Mobile Number | मोबाइल',mobile,'10 digit',keyboard:TextInputType.phone),const SizedBox(height:12),_field('Username | यूजरनेम',username,'username'),const SizedBox(height:12),_field('Password | पासवर्ड',password,'कम से कम 8 characters',obscure:true),const SizedBox(height:12),_field('Confirm Password | पुष्टि',confirm,'password again',obscure:true),const SizedBox(height:12),
      _locationDropdown(),
      if(role=='worker')...[const SizedBox(height:12),_professionDropdown(),const SizedBox(height:12),_field('Other Profession | अन्य',otherProfession,'Only if Other Profession')],
      const SizedBox(height:12),_field('Aadhaar Number | आधार',aadhaar,'12 digit',keyboard:TextInputType.number),const SizedBox(height:12),
      _profilePhotoTile(),const SizedBox(height:10),
      _photoTile('Aadhaar Photo | आधार फोटो',aadhaarPhoto,()async{final x=await _image(cameraOnly:false);if(x!=null)setState(()=>aadhaarPhoto=x);}),
      if(role=='worker')...[const SizedBox(height:10),_photoTile('Live Verification Photo | Live फोटो (Camera only)',livePhoto,()async{final x=await _image(cameraOnly:true);if(x!=null)setState(()=>livePhoto=x);})],
      const SizedBox(height:20),SizedBox(height:52,child:FilledButton(onPressed:busy?null:_register,child:Text(busy?'Creating...':'Create Account | अकाउंट बनाएं')))
    ]));
  }

  Widget _profilePhotoTile(){
    return InkWell(
      onTap:()async{final x=await _image(cameraOnly:false);if(x!=null)setState(()=>profilePhoto=x);},
      borderRadius:BorderRadius.circular(12),
      child:Container(
        padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(borderRadius:BorderRadius.circular(12),border:Border.all(color:FlutterFlowTheme.of(context).alternate)),
        child:Row(children:[
          CircleAvatar(radius:30,backgroundImage:profilePhoto!=null?NetworkImage(profilePhoto!.path):null,child:profilePhoto==null?const Icon(Icons.person,size:32):null),
          const SizedBox(width:14),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(profilePhoto==null?'Profile Photo | प्रोफाइल फोटो *':'Profile Photo | प्रोफाइल फोटो ✓',style:const TextStyle(fontWeight:FontWeight.w600)),
            const SizedBox(height:4),
            Text(profilePhoto==null?'Required • Camera या Gallery से photo चुनें':'Photo selected • Tap to change'),
          ])),
          const Icon(Icons.camera_alt_outlined),
        ]),
      ),
    );
  }

  Widget _locationDropdown(){return DropdownButtonFormField<int>(value:locationId,isExpanded:true,menuMaxHeight:420,decoration:const InputDecoration(labelText:'Chaupal Location | चौपाल लोकेशन',hintText:'Select Chaupal Location',border:OutlineInputBorder(),suffixIcon:Icon(Icons.location_on_outlined)),items:loadingMasters?const []:locations.map((x){final id=(x['id'] as num).toInt();return DropdownMenuItem<int>(value:id,child:Text('${x['display_name']}',overflow:TextOverflow.ellipsis));}).toList(),onChanged:loadingMasters?null:(v)=>setState(()=>locationId=v));}
  Widget _professionDropdown(){return DropdownButtonFormField<int>(value:professionId,isExpanded:true,menuMaxHeight:420,decoration:const InputDecoration(labelText:'Profession | प्रोफेशन',hintText:'Select Profession',border:OutlineInputBorder(),suffixIcon:Icon(Icons.work_outline)),items:professions.map((x){final id=(x['id'] as num).toInt();return DropdownMenuItem<int>(value:id,child:Text('${x['display_name']}',overflow:TextOverflow.ellipsis));}).toList(),onChanged:(v)=>setState(()=>professionId=v));}
  Widget _field(String label,TextEditingController c,String hint,{TextInputType? keyboard,bool obscure=false})=>TextField(controller:c,keyboardType:keyboard,obscureText:obscure,decoration:InputDecoration(labelText:label,hintText:hint,border:const OutlineInputBorder()));
  Widget _photoTile(String label,XFile? file,VoidCallback onTap)=>ListTile(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10),side:BorderSide(color:FlutterFlowTheme.of(context).alternate)),title:Text(file==null?label:'$label ✓'),subtitle:Text(file==null?'Required':'Photo selected'),trailing:const Icon(Icons.upload_file_outlined),onTap:onTap);
}