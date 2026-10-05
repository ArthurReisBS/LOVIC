// Ainda não há tabela de conversas (CP06): a lista começa vazia, sem contatos
// de exemplo. As conversas são abertas pelo botão de mensagem do perfil.
import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';

class ConversationsScreen extends StatelessWidget{
  const ConversationsScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const SizedBox(height:16),const Center(child:LovicLogo(fontSize:32)),const SizedBox(height:8),
      Padding(padding:const EdgeInsets.symmetric(horizontal:24),child:Text('Chats',style:AppTextStyles.heading)),
      const SizedBox(height:12),
      Expanded(child:Center(child:Padding(padding:const EdgeInsets.symmetric(horizontal:32),child:Text('Você ainda não tem conversas.\nToque em mensagem no perfil de alguém para começar!',textAlign:TextAlign.center,style:AppTextStyles.hint))))
    ]))),
    bottomNavigationBar:AppBottomNav(currentIndex:3,onTap:(i)=>goToTab(context,i))
  );
}
