import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ict_app/authentication/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ICT App", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
            });
            }, 
            icon: const Icon(Icons.logout, color: Colors.white,)
          )
        ],
      ),
      body: const Center(
        child: Text("Home", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
      ),
    );
  }
}