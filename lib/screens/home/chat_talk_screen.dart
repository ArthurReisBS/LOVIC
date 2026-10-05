// Mensagens só existem na tela (sem tabela de chat ainda, CP06): tudo que é
// enviado aparece do lado do usuário e nada é inventado pelo outro lado.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/ui/em_breve.dart';
import '../../models/user_profile.dart';
import '../../widgets/shared/app_background.dart';

class ChatTalkScreen extends StatefulWidget{
  final UserProfile profile;
  const ChatTalkScreen({super.key,required this.profile});
  @override State<ChatTalkScreen> createState()=>_ChatTalkScreenState();
}
class _ChatTalkScreenState extends State<ChatTalkScreen>{
  final _controller=TextEditingController();
  final List<String> _messages=[];
  @override void dispose(){_controller.dispose();super.dispose();}
  void _send(){final text=_controller.text.trim();if(text.isEmpty)return;setState((){_messages.add(text);_controller.clear();});}
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
      Expanded(child:_messages.isEmpty?Center(child:Text('Diga oi para ${widget.profile.name}!',style:AppTextStyles.hint)):ListView.builder(padding:const EdgeInsets.fromLTRB(24,28,24,20),itemCount:_messages.length,itemBuilder:(context,index){
        return Align(alignment:Alignment.centerRight,child:Container(
          margin:const EdgeInsets.only(bottom:24),padding:const EdgeInsets.symmetric(horizontal:20,vertical:14),
          decoration:BoxDecoration(color:AppColors.specialGradientStart,borderRadius:BorderRadius.circular(22)),
          child:Text(_messages[index],style:AppTextStyles.body)));
      })),
      Padding(padding:const EdgeInsets.fromLTRB(16,8,16,12),child:Row(children:[
        IconButton(onPressed:()=>mostrarEmBreve(context,'Câmera chega no CP06.'),icon:const Icon(Icons.camera_alt_outlined)),
        Expanded(child:TextField(controller:_controller,style:AppTextStyles.body,decoration:InputDecoration(hintText:'Digite uma mensagem...',hintStyle:AppTextStyles.hint,filled:true,fillColor:AppColors.surfaceDark,border:OutlineInputBorder(borderRadius:BorderRadius.circular(28),borderSide:BorderSide.none)),onSubmitted:(_)=>_send())),
        const SizedBox(width:8),
        DecoratedBox(decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.primary),child:IconButton(onPressed:_send,icon:const Icon(Icons.send,color:Colors.white)))
      ]))
    ])))
  );
}
