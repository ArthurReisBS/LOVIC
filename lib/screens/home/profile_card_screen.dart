import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/profile_card.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'chat_talk_screen.dart';
import 'profile_detail_screen.dart';

class ProfileCardScreen extends StatefulWidget{
  const ProfileCardScreen({super.key});
  @override State<ProfileCardScreen> createState()=>_ProfileCardScreenState();
}
class _ProfileCardScreenState extends State<ProfileCardScreen>{
  final _controller=PageController();
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:Column(children:[
      const SizedBox(height:4),const LovicLogo(fontSize:22),const SizedBox(height:4),
      Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:6),child:PageView.builder(controller:_controller,itemCount:mockProfiles.length,itemBuilder:(context,index){
        final p=mockProfiles[index];
        return Padding(padding:const EdgeInsets.only(bottom:4),child:ProfileCard(
          profile:p,
          onViewProfile:()=>Navigator.of(context).push(noTransitionRoute(ProfileDetailScreen(profile:p))),
          onMessage:()=>Navigator.of(context).push(noTransitionRoute(ChatTalkScreen(profile:p))),
        ));
      })))
    ]))),
    bottomNavigationBar:AppBottomNav(currentIndex:1,onTap:(i)=>goToTab(context,i))
  );
}
