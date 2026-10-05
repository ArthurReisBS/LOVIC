import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../widgets/home/genre_chip.dart';
import '../../widgets/shared/app_background.dart';

class ProfileDetailScreen extends StatelessWidget{
  final UserProfile profile;
  const ProfileDetailScreen({super.key,required this.profile});
  // Perfil real (com id) só mostra o que existe no banco: a idade. Perfis de
  // exemplo mantêm as informações fixas.
  List<_Info> get _infos{
    if(profile.id==null){
      return const [_Info('Gênero','Mulher cisgênero'),_Info('Sexualidade','Bissexual'),_Info('Idade','19'),_Info('Altura','1,65 m'),_Info('Signo','Câncer (13/07/2007)')];
    }
    return [if(profile.age!=null)_Info('Idade','${profile.age}')];
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:AppBackground(child:SafeArea(child:CustomScrollView(slivers:[
      SliverAppBar(backgroundColor:Colors.transparent,leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.chevron_left)),actions:[IconButton(onPressed:(){},icon:const Icon(Icons.more_vert))]),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(24,8,24,32),child:Column(children:[
        ClipRRect(borderRadius:BorderRadius.circular(28),child:SizedBox(width:280,height:280,child:profile.photoAsset!=null?Image.asset(profile.photoAsset!,fit:BoxFit.cover):Container(color:profile.photoColor,child:Center(child:Text(profile.name.substring(0,1),style:const TextStyle(fontSize:72)))))),
        const SizedBox(height:20),Text(profile.name,style:AppTextStyles.screenTitle.copyWith(fontSize:32)),
        Text('@${profile.username??profile.name.toLowerCase().replaceAll(' ', '.')}',style:AppTextStyles.hint),const SizedBox(height:24),
        Wrap(alignment:WrapAlignment.center,spacing:8,runSpacing:8,children:profile.genres.map((g)=>GenreChip(label:g.name,variant:g.variant)).toList()),
        const SizedBox(height:30),Text('Sobre mim',style:AppTextStyles.heading),const SizedBox(height:14),
        Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:AppColors.surfaceDark,borderRadius:BorderRadius.circular(22)),child:Text(profile.bio,style:AppTextStyles.body)),
        if(_infos.isNotEmpty)...[
          const SizedBox(height:28),Align(alignment:Alignment.centerLeft,child:Text('Informações Pessoais',style:AppTextStyles.heading)),const SizedBox(height:16),
          ..._infos
        ]
      ])))
    ])))
  );
}
class _Info extends StatelessWidget{
  final String label,value;const _Info(this.label,this.value);
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[SizedBox(width:150,child:Text(label,style:AppTextStyles.hint)),Expanded(child:Text(value,style:AppTextStyles.body))]));
}
