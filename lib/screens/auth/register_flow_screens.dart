import 'package:flutter/material.dart';
import '../../core/navigation/no_transition_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/gradient_blob_background.dart';
import '../../widgets/auth/gradient_button.dart';
import '../../widgets/shared/lovic_logo.dart';
import '../home/home_screen.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});
  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}
class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  @override
  void dispose(){for(final c in _controllers)c.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>_RegisterScaffold(child:Column(children:[
    const LovicLogo(fontSize:64),const SizedBox(height:48),
    Text('Digite o código que enviamos para o email: teste@email.com',style:AppTextStyles.heading,textAlign:TextAlign.center),
    const SizedBox(height:48),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(6,(i)=>Padding(
      padding:EdgeInsets.only(right:i==5?0:8),
      child:SizedBox(width:48,child:AuthTextField(controller:_controllers[i],keyboardType:TextInputType.number,hintText:'')),
    ))),
    const SizedBox(height:28),
    TextButton(onPressed:(){},child:Text('Reenviar código',style:AppTextStyles.linkOrange)),
    const SizedBox(height:24),
    GradientButton(label:'Confirmar',onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterPersonalScreen()))),
  ]));
}

class RegisterPersonalScreen extends StatefulWidget {
  const RegisterPersonalScreen({super.key});
  @override State<RegisterPersonalScreen> createState()=>_RegisterPersonalScreenState();
}
class _RegisterPersonalScreenState extends State<RegisterPersonalScreen>{
  final _name=TextEditingController(),_surname=TextEditingController(),_birth=TextEditingController();
  @override void dispose(){_name.dispose();_surname.dispose();_birth.dispose();super.dispose();}
  Future<void> _pickDate()async{
    final d=await showDatePicker(context:context,firstDate:DateTime(1900),lastDate:DateTime.now(),initialDate:DateTime(2005));
    if(d!=null)_birth.text='${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }
  @override Widget build(BuildContext context)=>_RegisterScaffold(compact:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Center(child:LovicLogo(fontSize:38)),const SizedBox(height:42),
    Center(child:Text('Fale um pouco sobre você',style:AppTextStyles.heading,textAlign:TextAlign.center)),
    const SizedBox(height:38),Text('Nome:',style:AppTextStyles.bodyBold),const SizedBox(height:10),
    AuthTextField(controller:_name,hintText:'Digite seu nome...'),const SizedBox(height:24),
    Text('Sobrenome:',style:AppTextStyles.bodyBold),const SizedBox(height:10),
    AuthTextField(controller:_surname,hintText:'Digite seu sobrenome...'),const SizedBox(height:24),
    Text('Data de nascimento:',style:AppTextStyles.bodyBold),const SizedBox(height:10),
    AuthTextField(controller:_birth,hintText:'Selecione sua data...',readOnly:true,borderColor:AppColors.fieldBorderNeutral,
      suffixIcon:const Icon(Icons.calendar_month_outlined,color:AppColors.primary),onTap:_pickDate),
    const SizedBox(height:32),
    GradientButton(label:'Avançar',onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterProfileScreen()))),
  ]));
}

class RegisterProfileScreen extends StatefulWidget{
  const RegisterProfileScreen({super.key});
  @override State<RegisterProfileScreen> createState()=>_RegisterProfileScreenState();
}
class _RegisterProfileScreenState extends State<RegisterProfileScreen>{
  final _username=TextEditingController();
  @override void dispose(){_username.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_RegisterScaffold(compact:true,child:Column(children:[
    const LovicLogo(fontSize:38),const SizedBox(height:42),
    Text('Vamos personalizar seu perfil',style:AppTextStyles.heading,textAlign:TextAlign.center),const SizedBox(height:42),
    GestureDetector(onTap:(){},child:Container(width:180,height:180,decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.surfaceDark),
      alignment:Alignment.center,child:const Text('T',style:TextStyle(fontSize:64,color:AppColors.textPrimary)))),
    const SizedBox(height:12),Text('Escolha sua melhor foto',style:AppTextStyles.hint),const SizedBox(height:30),
    Align(alignment:Alignment.centerLeft,child:Text('Username:',style:AppTextStyles.bodyBold)),const SizedBox(height:10),
    AuthTextField(controller:_username,hintText:'Digite um username...'),const SizedBox(height:28),
    GradientButton(label:'Avançar',onPressed:()=>Navigator.of(context).push(noTransitionRoute(const RegisterPasswordScreen()))),
  ]));
}

class RegisterPasswordScreen extends StatefulWidget{
  const RegisterPasswordScreen({super.key});
  @override State<RegisterPasswordScreen> createState()=>_RegisterPasswordScreenState();
}
class _RegisterPasswordScreenState extends State<RegisterPasswordScreen>{
  final _password=TextEditingController(),_confirm=TextEditingController();
  @override void dispose(){_password.dispose();_confirm.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>_RegisterScaffold(compact:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Center(child:LovicLogo(fontSize:38)),const SizedBox(height:44),
    Center(child:Text('Agora vamos manter sua conta segura',style:AppTextStyles.heading,textAlign:TextAlign.center)),const SizedBox(height:42),
    Text('Senha:',style:AppTextStyles.bodyBold),const SizedBox(height:10),
    AuthTextField(controller:_password,hintText:'Digite uma senha forte...',obscureText:true),const SizedBox(height:24),
    Text('Confirme a senha:',style:AppTextStyles.bodyBold),const SizedBox(height:10),
    AuthTextField(controller:_confirm,hintText:'Digite a mesma senha...',obscureText:true),const SizedBox(height:34),
    GradientButton(label:'Criar conta',onPressed:()=>Navigator.of(context).pushAndRemoveUntil(noTransitionRoute(const HomeScreen()),(_)=>false)),
  ]));
}

class _RegisterScaffold extends StatelessWidget{
  final Widget child;final bool compact;
  const _RegisterScaffold({required this.child,this.compact=false});
  @override Widget build(BuildContext context)=>Scaffold(
    body:GradientBlobBackground(blobScale: compact ? .58 : 1,child:SafeArea(child:SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(28,24,28,32),
      child:ConstrainedBox(constraints:BoxConstraints(minHeight:0),child:Align(alignment:Alignment.topCenter,child:child)),
    ))),
  );
}
