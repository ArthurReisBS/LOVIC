import 'package:flutter/material.dart';
import 'no_transition_route.dart';
import '../../screens/home/conversations_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/my_profile_screen.dart';
import '../../screens/home/profile_card_screen.dart';
import '../../screens/home/settings_screen.dart';

void goToTab(BuildContext context,int index){
  final Widget screen=switch(index){
    0=>const MyProfileScreen(),
    1=>const ProfileCardScreen(),
    2=>const HomeScreen(),
    3=>const ConversationsScreen(),
    _=>const SettingsScreen(),
  };
  Navigator.of(context).pushReplacement(noTransitionRoute(screen));
}
