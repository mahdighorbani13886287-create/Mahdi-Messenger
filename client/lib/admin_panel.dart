import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api');

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});
  @override State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final maxFile = TextEditingController(text: '5');
  final quota = TextEditingController(text: '20');
  final word = TextEditingController();
  final username = TextEditingController();
  String mode = 'custom', wordAction = 'block', role = 'moderator', status = 'در حال اتصال...';
  bool loading = true;
  List<dynamic> words = [], admins = [];
  @override void initState() { super.initState(); load(); }
  @override void dispose() { maxFile.dispose(); quota.dispose(); word.dispose(); username.dispose(); super.dispose(); }

  Future<void> load() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$apiBaseUrl/admin/settings')),
        http.get(Uri.parse('$apiBaseUrl/admin/banned-words')),
        http.get(Uri.parse('$apiBaseUrl/admin/admins')),
      ]);
      for (final r in responses) { if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}'); }
      final s = jsonDecode(responses[0].body);
      setState(() { maxFile.text='${s['maxFileSizeGb']}'; quota.text='${s['userQuotaGb']}'; mode=s['fileLimitMode']; words=jsonDecode(responses[1].body); admins=jsonDecode(responses[2].body); loading=false; status='اتصال به API برقرار است'; });
    } catch (e) { setState(() { loading=false; status='اتصال برقرار نشد: $e'; }); }
  }
  Future<void> save() async {
    final r=await http.put(Uri.parse('$apiBaseUrl/admin/settings'), headers:{'Content-Type':'application/json'}, body:jsonEncode({'fileLimitMode':mode,'maxFileSizeGb':double.tryParse(maxFile.text)??5,'userQuotaGb':double.tryParse(quota.text)??20}));
    setState(()=>status=r.statusCode==200?'تنظیمات ذخیره شد':'خطا در ذخیره (${r.statusCode})'); await load();
  }
  Future<void> addWord() async {
    final r=await http.post(Uri.parse('$apiBaseUrl/admin/banned-words'),headers:{'Content-Type':'application/json'},body:jsonEncode({'word':word.text.trim(),'action':wordAction}));
    if(r.statusCode==201||r.statusCode==200){word.clear();await load();}else{setState(()=>status='خطا: ${r.body}');}
  }
  Future<void> addAdmin() async {
    final r=await http.post(Uri.parse('$apiBaseUrl/admin/admins'),headers:{'Content-Type':'application/json'},body:jsonEncode({'username':username.text.trim(),'role':role}));
    if(r.statusCode==201||r.statusCode==200){username.clear();await load();}else{setState(()=>status='خطا: ${r.body}');}
  }
  Future<void> deleteWord(String id) async { await http.delete(Uri.parse('$apiBaseUrl/admin/banned-words/$id')); await load(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('پنل مدیریت Mahdi Messenger'), actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh))]),
    body: loading ? const Center(child:CircularProgressIndicator()) : ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(12),child:Text(status))),
      _section('تنظیمات انتقال فایل',[
        DropdownButtonFormField<String>(value:mode,decoration:const InputDecoration(labelText:'حالت محدودیت'),items:const [DropdownMenuItem(value:'custom',child:Text('قابل تنظیم از پنل')),DropdownMenuItem(value:'unlimited',child:Text('بدون سقف ثابت؛ تابع ظرفیت سرور'))],onChanged:(v)=>setState(()=>mode=v??'custom')),
        TextField(controller:maxFile,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'حداکثر حجم هر فایل (GB)')),
        TextField(controller:quota,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'سهمیه هر کاربر (GB)')),
        FilledButton(onPressed:save,child:const Text('ذخیره تنظیمات')),
        const Text('مقادیر سیاستی هستند؛ سقف واقعی به فضای دیسک، شبکه و تنظیمات پراکسی هم وابسته است.',style:TextStyle(fontSize:12)),
      ]),
      _section('فیلتر کلمات',[
        TextField(controller:word,decoration:const InputDecoration(labelText:'کلمه یا عبارت ممنوع')),
        DropdownButtonFormField<String>(value:wordAction,decoration:const InputDecoration(labelText:'عملکرد'),items:const [DropdownMenuItem(value:'block',child:Text('جلوگیری از ارسال')),DropdownMenuItem(value:'replace',child:Text('جایگزینی')),DropdownMenuItem(value:'warn',child:Text('هشدار'))],onChanged:(v)=>setState(()=>wordAction=v??'block')),
        FilledButton(onPressed:addWord,child:const Text('افزودن کلمه')),
        ...words.map((w)=>ListTile(title:Text('${w['word']}'),subtitle:Text('عملکرد: ${w['action']}'),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>deleteWord('${w['id']}')))),
      ]),
      _section('مدیران و نقش‌ها',[
        TextField(controller:username,decoration:const InputDecoration(labelText:'نام کاربری مدیر جدید')),
        DropdownButtonFormField<String>(value:role,decoration:const InputDecoration(labelText:'نقش'),items:const [DropdownMenuItem(value:'admin',child:Text('مدیر')),DropdownMenuItem(value:'moderator',child:Text('ناظر')),DropdownMenuItem(value:'support',child:Text('پشتیبانی'))],onChanged:(v)=>setState(()=>role=v??'moderator')),
        FilledButton(onPressed:addAdmin,child:const Text('افزودن مدیر')),
        ...admins.map((a)=>ListTile(title:Text('${a['username']}'),subtitle:Text('نقش: ${a['role']}'))),
      ]),
      const Card(color:Color(0x33FF5252),child:Padding(padding:EdgeInsets.all(12),child:Text('هشدار امنیتی: API مدیریت فعلاً احراز هویت و مجوزدهی ندارد و داده‌ها موقت‌اند. فقط روی localhost تست کنید؛ روی اینترنت عمومی منتشر نکنید.'))),
    ]),
  );
  Widget _section(String title,List<Widget> children)=>Card(margin:const EdgeInsets.only(bottom:14),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:10),...children])));
}
