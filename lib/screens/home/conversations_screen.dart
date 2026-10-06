// Conversas salvas em public.mensagens (ChatService), a mais recente no topo.
// Novas conversas são abertas pelo botão de mensagem do perfil.
import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/chat_service.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'chat_talk_screen.dart';

class ConversationsScreen extends StatefulWidget{
  const ConversationsScreen({super.key});
  @override State<ConversationsScreen> createState()=>_ConversationsScreenState();
}
class _ConversationsScreenState extends State<ConversationsScreen>{
  List<ChatConversation> _conversations=[];
  bool _loading=true;
  String? _error;

  @override void initState(){super.initState();_load();}

  Future<void> _load()async{
    setState((){_loading=true;_error=null;});
    try{
      final conversations=await ChatService.fetchConversations();
      if(mounted)setState((){_conversations=conversations;_loading=false;});
    }catch(e){
      if(mounted)setState((){_error=e.toString();_loading=false;});
    }
  }

  // Ao voltar do chat a última mensagem pode ter mudado.
  Future<void> _open(ChatConversation conversation)async{
    await Navigator.of(context).push(noTransitionRoute(ChatTalkScreen(profile:conversation.profile)));
    if(mounted)_load();
  }

  Widget _body(){
    if(_loading)return const Center(child:CircularProgressIndicator());
    if(_error!=null)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(_error!,textAlign:TextAlign.center,style:AppTextStyles.hint),TextButton(onPressed:_load,child:const Text('Tentar de novo'))]));
    if(_conversations.isEmpty)return Center(child:Padding(padding:const EdgeInsets.symmetric(horizontal:32),child:Text('Você ainda não tem conversas.\nToque em mensagem no perfil de alguém para começar!',textAlign:TextAlign.center,style:AppTextStyles.hint)));
    return RefreshIndicator(onRefresh:_load,child:ListView.separated(padding:const EdgeInsets.symmetric(horizontal:24,vertical:8),itemCount:_conversations.length,separatorBuilder:(_,_)=>const SizedBox(height:12),
      itemBuilder:(context,i)=>_ConversationTile(conversation:_conversations[i],onTap:()=>_open(_conversations[i]))));
  }

  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const SizedBox(height:16),const Center(child:LovicLogo(fontSize:32)),const SizedBox(height:8),
      Padding(padding:const EdgeInsets.symmetric(horizontal:24),child:Text('Chats',style:AppTextStyles.heading)),
      const SizedBox(height:12),
      Expanded(child:_body())
    ]))),
    bottomNavigationBar:AppBottomNav(currentIndex:3,onTap:(i)=>goToTab(context,i))
  );
}

/// Hoje mostra a hora; outros dias, a data.
String _horario(DateTime sentAt){
  final now=DateTime.now();String two(int n)=>n.toString().padLeft(2,'0');
  final today=sentAt.year==now.year&&sentAt.month==now.month&&sentAt.day==now.day;
  return today?'${two(sentAt.hour)}:${two(sentAt.minute)}':'${two(sentAt.day)}/${two(sentAt.month)}';
}

class _ConversationTile extends StatelessWidget{
  final ChatConversation conversation;final VoidCallback onTap;
  const _ConversationTile({required this.conversation,required this.onTap});
  @override Widget build(BuildContext context){final p=conversation.profile;final last=conversation.lastMessage;return HoverScale(scale:1.02,child:GestureDetector(
    onTap:onTap,
    child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.surfaceDark,borderRadius:BorderRadius.circular(18)),child:Row(children:[
      CircleAvatar(radius:26,backgroundColor:p.photoColor,backgroundImage:p.photoAsset!=null?AssetImage(p.photoAsset!):p.photoUrl!=null?NetworkImage(p.photoUrl!) as ImageProvider:null),const SizedBox(width:14),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(p.name,style:AppTextStyles.bodyBold),const SizedBox(height:4),Text(last.isMine?'Você: ${last.text}':last.text,style:AppTextStyles.hint,maxLines:1,overflow:TextOverflow.ellipsis)])),
      const SizedBox(width:8),Text(_horario(last.sentAt),style:AppTextStyles.hint)
    ]))
  ));}
}
