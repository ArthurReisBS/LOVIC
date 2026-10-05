import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/shared/hover_scale.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  final _email=TextEditingController(),_password=TextEditingController();
  bool _loading=false;
  @override void dispose(){_email.dispose();_password.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    body:GradientBlobBackground(child:SafeArea(child:LayoutBuilder(builder:(context,constraints)=>SingleChildScrollView(
      padding:const EdgeInsets.symmetric(horizontal:28,vertical:24),
      child:ConstrainedBox(constraints:BoxConstraints(minHeight:constraints.maxHeight),child:Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
        const LovicLogo(fontSize:64),Text('Bem-vindo!',style:AppTextStyles.heading),
        AuthTextField(controller:_email,hintText:'Digite seu email...',keyboardType:TextInputType.emailAddress),
        const SizedBox(height:16),
        AuthTextField(controller:_password,hintText:'Digite sua senha...',obscureText:true),
        const SizedBox(height:20),
        GradientButton(label:_loading?'Entrando...':'Entrar',onPressed:_loading?null:_signIn),
        const _OrDivider(),
        SocialLoginButton(icon:Padding(padding:const EdgeInsets.only(left:20),child:SizedBox(width:20,height:20,child:SvgPicture.asset('assets/images/google_logo.svg'))),label:'Login com Google',backgroundColor:AppColors.socialButtonLight,textColor:AppColors.textSecondary,onPressed:_socialLogin),
        const SizedBox(height:16),
        SocialLoginButton(icon:const Padding(padding:EdgeInsets.only(left:20),child:FaIcon(FontAwesomeIcons.spotify,color:AppColors.spotifyGreen,size:22)),label:'Login com Spotify',backgroundColor:AppColors.socialButtonSpotify,textColor:AppColors.textPrimary,onPressed:_socialLogin),
        const SizedBox(height:24),
        HoverScale(child:GestureDetector(onTap:()=>Navigator.of(context).push(noTransitionRoute(const RegisterScreen())),child:Text('Criar uma conta',style:AppTextStyles.linkOrange)))
      ])),
    ))))
  );
  Future<void> _signIn()async{
    final email=_email.text.trim(),password=_password.text;
    // Sem .env: modo demonstração, entra direto como antes.
    if(!SupabaseConfig.isConfigured)return _goHome(context);
    if(email.isEmpty||password.isEmpty)return _showError('Preencha o email e a senha.');
    setState(()=>_loading=true);
    try{
      await AuthService.signIn(email,password);
      if(mounted)_goHome(context);
    }on AuthFailure catch(e){
      _showError(e.message);
    }finally{
      if(mounted)setState(()=>_loading=false);
    }
  }
  // Google e Spotify chegam no CP06. Com banco, entrar na Home sem sessão
  // deixaria o Meu Perfil vazio, então só avisa; na demonstração entra direto.
  void _socialLogin(){
    if(SupabaseConfig.isConfigured)return _showError('Login com Google/Spotify chega no CP06. Use email e senha.');
    _goHome(context);
  }
  void _showError(String message)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));
  void _goHome(BuildContext context)=>Navigator.of(context).pushAndRemoveUntil(noTransitionRoute(const HomeScreen()),(_)=>false);
}
class _OrDivider extends StatelessWidget{
  const _OrDivider();
  @override Widget build(BuildContext context)=>Row(children:[
    Expanded(child:Divider(color:AppColors.textMuted.withValues(alpha:.4))),
    Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Text('ou',style:AppTextStyles.hint)),
    Expanded(child:Divider(color:AppColors.textMuted.withValues(alpha:.4)))
  ]);
}
