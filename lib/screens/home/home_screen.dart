import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/navigation/app_tabs.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/music_genres.dart';
import '../../core/ui/em_breve.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/home/app_bottom_nav.dart';
import '../../widgets/home/home_genre_chip.dart';
import '../../widgets/shared/app_background.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'notification_screen.dart';
import 'profile_card_screen.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(24,24,24,16),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        SizedBox(width:double.infinity,height:40,child:Stack(alignment:Alignment.center,children:[
          const LovicLogo(fontSize:34),
          Positioned(right:0,child:GestureDetector(onTap:()=>Navigator.of(context).push(noTransitionRoute(const NotificationScreen())),child:const _NotificationBell()))
        ])),
        const SizedBox(height:28),const _SearchBar(),const SizedBox(height:24),const _MapWithBlobs(),
        const SizedBox(height:10),Text('Localização atual',style:AppTextStyles.hint),const SizedBox(height:32),
        GradientButton(label:'Encontre um par',height:50,onPressed:()=>Navigator.of(context).push(noTransitionRoute(const ProfileCardScreen()))),
        const SizedBox(height:40),Text('Explore gêneros musicais',style:AppTextStyles.bodyBold),const SizedBox(height:18),
        SizedBox(height:30,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:availableGenres.length,separatorBuilder:(_,_)=>const SizedBox(width:8),itemBuilder:(context,i){
          final g=genreFromName(availableGenres[i]);return HomeGenreChip(label:g.name,variant:g.variant,onTap:()=>Navigator.of(context).push(noTransitionRoute(ProfileCardScreen(genreFilter:g.name))));
        })),
      ])
    ))),
    bottomNavigationBar:AppBottomNav(currentIndex:2,onTap:(i)=>goToTab(context,i))
  );
}
class _NotificationBell extends StatelessWidget{
  const _NotificationBell();
  @override Widget build(BuildContext context)=>Stack(clipBehavior:Clip.none,children:[
    const Icon(Icons.notifications_none,color:Colors.white70,size:26),
    if(notificacoesDeExemplo>0)Positioned(right:-2,top:-2,child:Container(width:14,height:14,alignment:Alignment.center,decoration:const BoxDecoration(color:AppColors.primary,shape:BoxShape.circle),child:Text('$notificacoesDeExemplo',style:TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold))))
  ]);
}
// Busca por lugares ainda não existe: avisa uma vez ao tocar, sem travar a digitação.
class _SearchBar extends StatefulWidget{
  const _SearchBar();
  @override State<_SearchBar> createState()=>_SearchBarState();
}
class _SearchBarState extends State<_SearchBar>{
  bool _avisou=false;
  void _avisar(){
    if(_avisou)return;
    _avisou=true;
    mostrarEmBreve(context,'Busca por lugares chega no CP06.');
  }
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:16),decoration:BoxDecoration(border:Border.all(color:AppColors.primary),borderRadius:BorderRadius.circular(20)),child:TextField(onTap:_avisar,style:AppTextStyles.body,decoration:InputDecoration(isDense:true,contentPadding:const EdgeInsets.symmetric(vertical:10),border:InputBorder.none,hintText:'Procure um lugar...',hintStyle:AppTextStyles.hint,suffixIcon:const Icon(Icons.search,color:AppColors.primary,size:20))));
}
class _MapWithBlobs extends StatelessWidget{
  const _MapWithBlobs();
  @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(20),child:SizedBox(height:240,width:double.infinity,child:Stack(fit:StackFit.expand,children:[
    Image.asset('assets/images/map_placeholder.png',fit:BoxFit.cover),
    Positioned(top:-20,left:-10,child:_blob(140,AppColors.mapHeatPink)),
    Positioned(bottom:-30,left:70,child:_blob(160,AppColors.mapHeatYellow)),
    Positioned(right:12,bottom:12,child:HoverScale(child:GestureDetector(onTap:()=>mostrarEmBreve(context,'Localização chega no CP06.'),child:Container(width:32,height:32,decoration:const BoxDecoration(color:AppColors.primary,shape:BoxShape.circle),child:const Icon(Icons.my_location,color:Colors.white,size:16)))))
  ])));
  static Widget _blob(double size,Color color)=>ImageFiltered(imageFilter:ImageFilter.blur(sigmaX:22,sigmaY:22),child:Container(width:size,height:size,decoration:BoxDecoration(color:color.withValues(alpha:.55),shape:BoxShape.circle)));
}
