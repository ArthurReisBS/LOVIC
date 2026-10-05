import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import 'register_flow_screens.dart';

class RegisterScreen extends StatelessWidget{
  const RegisterScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(
    body:GradientBlobBackground(child:SafeArea(child:SingleChildScrollView(
      padding:const EdgeInsets.symmetric(horizontal:28,vertical:24),
      child:ConstrainedBox(constraints:BoxConstraints(minHeight:MediaQuery.sizeOf(context).height-48),child:Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
        const LovicLogo(fontSize:64),Text('Novo aqui?',style:AppTextStyles.heading),
        const AuthTextField(hintText:'Digite seu melhor email...'),
        Row(children:[Expanded(child:Divider(color:AppColors.textMuted.withValues(alpha:.4))),Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Text('ou',style:AppTextStyles.hint)),Expanded(child:Divider(color:AppColors.textMuted.withValues(alpha:.4)))]),
        SocialLoginButton(icon:Padding(padding:const EdgeInsets.only(left:20),child:SizedBox(width:20,height:20,child:SvgPicture.asset('assets/images/google_logo.svg'))),label:'Criar com Google',backgroundColor:AppColors.socialButtonLight,textColor:AppColors.textSecondary,onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterPersonalScreen()))),
        const SizedBox(height:16),
        SocialLoginButton(icon:const Padding(padding:EdgeInsets.only(left:20),child:FaIcon(FontAwesomeIcons.spotify,color:AppColors.spotifyGreen,size:22)),label:'Criar com Spotify',backgroundColor:AppColors.socialButtonSpotify,textColor:AppColors.textPrimary,onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterPersonalScreen()))),
        const SizedBox(height:24),
        HoverScale(child:GestureDetector(onTap:()=>Navigator.pop(context),child:Text('Já tem uma conta?',style:AppTextStyles.linkOrange))),
        TextButton(onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterOtpScreen())),child:Text('Continuar com email',style:AppTextStyles.linkOrange))
      ]))
    )))
  );
}
