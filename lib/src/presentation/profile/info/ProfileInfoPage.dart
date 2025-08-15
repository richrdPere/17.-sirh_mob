import 'package:flutter/material.dart';
import 'package:sirh_mob/src/presentation/profile/info/ProfileInfoContent.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  @override
  Widget build(BuildContext context) {
    return ProfileInfoContent();
    // return Scaffold(
    //   body: Center(
    //     child: Text('ProfileInfoPage'),
    //   ),
    // );
  }
}