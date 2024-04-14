import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ict_app/authentication/login_screen.dart';
import 'package:ict_app/screens/tabs_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen>{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  
  startTimer() {
    Timer(const Duration(seconds: 3), () async
    {
      //if user is loggedin already
      if(firebaseAuth.currentUser != null)
      {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const TabsScreen()));
      }
      //if user is NOT loggedin already
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("assets/login.png"),
              ),

              const SizedBox(height: 10,),

              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Google Map Services App.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
