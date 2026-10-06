// Mensagens salvas em public.mensagens (ChatService) e recebidas em tempo
// real. Em modo demonstração, ou com um perfil de exemplo, ficam só na tela.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/ui/em_breve.dart';
import '../../models/user_profile.dart';
import '../../services/chat_service.dart';
import '../../widgets/shared/app_background.dart';

class ChatTalkScreen extends StatefulWidget{
  final UserProfile profile;
  const ChatTalkScreen({super.key,required this.profile});
  @override State<ChatTalkScreen> createState()=>_ChatTalkScreenState();
}
class _ChatTalkScreenState extends State<ChatTalkScreen>{
  final _controller=TextEditingController();
  final List<ChatMessage> _messages=[];
  late final bool _persist=ChatService.canPersist(widget.profile.id);
  RealtimeChannel? _channel;
  bool _loading=false,_sending=false;
  String? _error;

  @override void initState(){
    super.initState();
    if(!_persist)return;
    _load();
    _channel=ChatService.listen(widget.profile.id!,_add);
  }
  @override void dispose(){
    final channel=_channel;
    if(channel!=null)ChatService.stopListening(channel);
    _controller.dispose();super.dispose();
  }

  Future<void> _load()async{
    setState((){_loading=true;_error=null;});
    try{
      final messages=await ChatService.fetchMessages(widget.profile.id!);
      if(!mounted)return;
      setState((){_messages..clear()..addAll(messages);_loading=false;});
    }catch(e){
      if(mounted)setState((){_error=e.toString();_loading=false;});
    }
  }

  // A mensagem enviada chega duas vezes (resposta do insert e tempo real).
  void _add(ChatMessage message){
    if(!mounted||_messages.any((m)=>m.id!=null&&m.id==message.id))return;
    setState(()=>_messages.add(message));
  }

  Future<void> _send()async{
    final text=_controller.text.trim();if(text.isEmpty||_sending)return;
    if(!_persist){setState((){_messages.add(ChatMessage(text:text,isMine:true,sentAt:DateTime.now()));_controller.clear();});return;}
    setState(()=>_sending=true);
    try{
      final message=await ChatService.sendMessage(widget.profile.id!,text);
      _controller.clear();_add(message);
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }finally{
      if(mounted)setState(()=>_sending=false);
    }
  }

  Widget _body(){
    if(_loading)return const Center(child:CircularProgressIndicator());
    if(_error!=null)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(_error!,textAlign:TextAlign.center,style:AppTextStyles.hint),TextButton(onPressed:_load,child:const Text('Tentar de novo'))]));
    if(_messages.isEmpty)return Center(child:Text('Diga oi para ${widget.profile.name}!',style:AppTextStyles.hint));
    return ListView.builder(reverse:true,padding:const EdgeInsets.fromLTRB(24,28,24,20),itemCount:_messages.length,itemBuilder:(context,index){
      final message=_messages[_messages.length-1-index];
      return Align(alignment:message.isMine?Alignment.centerRight:Alignment.centerLeft,child:Container(
        margin:const EdgeInsets.only(bottom:24),padding:const EdgeInsets.symmetric(horizontal:20,vertical:14),
        decoration:BoxDecoration(color:message.isMine?AppColors.specialGradientStart:AppColors.surfaceDark,borderRadius:BorderRadius.circular(22)),
        child:Text(message.text,style:AppTextStyles.body)));
    });
  }

  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:Column(children:[
      Container(padding:const EdgeInsets.fromLTRB(16,16,16,18),decoration:const BoxDecoration(color:AppColors.surfaceDark),
        child:Row(children:[
          IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.chevron_left)),
          CircleAvatar(radius:28,backgroundColor:widget.profile.photoColor,backgroundImage:widget.profile.photoAsset!=null?AssetImage(widget.profile.photoAsset!):widget.profile.photoUrl!=null?NetworkImage(widget.profile.photoUrl!) as ImageProvider:null),
          const SizedBox(width:14),
          Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.profile.name,style:AppTextStyles.bodyBold),Text(widget.profile.username!=null?'@${widget.profile.username}':'',style:AppTextStyles.hint)]),
          const Spacer(),IconButton(onPressed:()=>mostrarEmBreve(context),icon:const Icon(Icons.more_vert))
        ])),
      Expanded(child:_body()),
      Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:Row(children:[
        IconButton(onPressed:()=>mostrarEmBreve(context,'Câmera chega no CP06.'),icon:const Icon(Icons.camera_alt_outlined)),
        Expanded(child:TextField(controller:_controller,style:AppTextStyles.body,decoration:InputDecoration(hintText:'Digite uma mensagem...',hintStyle:AppTextStyles.hint,filled:true,fillColor:AppColors.surfaceDark,border:OutlineInputBorder(borderRadius:BorderRadius.circular(28),borderSide:BorderSide.none)),onSubmitted:(_)=>_send())),
        const SizedBox(width:8),
        DecoratedBox(decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.primary),child:IconButton(onPressed:_sending?null:_send,icon:const Icon(Icons.send,color:Colors.white)))
      ]))
    ])))
  );
}
