import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/shared/app_background.dart';

/// Quantidade de itens de exemplo mostrados abaixo; o sino da Home usa o
/// mesmo valor para o contador não mentir.
const int notificacoesDeExemplo=1;
class NotificationScreen extends StatelessWidget{
  const NotificationScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:Column(children:[
      const SizedBox(height:16),Text('Notificações',style:AppTextStyles.screenTitle.copyWith(fontSize:32)),const SizedBox(height:30),
      ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:24,vertical:8),
        leading:CircleAvatar(radius:34,backgroundColor:mockProfiles[1].photoColor),
        title:Text(mockProfiles[1].name,style:AppTextStyles.bodyBold),
        subtitle:Text('Começou a seguir você',style:AppTextStyles.body),
        trailing:const Icon(Icons.chevron_right,color:AppColors.iconInactive))
    ]))),
    bottomNavigationBar:AppBottomNav(currentIndex:2,onTap:(i)=>goToTab(context,i))
  );
}
