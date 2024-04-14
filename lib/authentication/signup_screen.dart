import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ict_app/authentication/login_screen.dart';
import 'package:ict_app/screens/map_screen.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoading = false;

  String email = "", password = "", name = "";

  File? pickedImageFile;

  pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      pickedImageFile = File(pickedImage!.path);
    });
  }

  signUp() async {
    try {
      if (pickedImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please pick an image",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        return; 
      }

      if (pickedImageFile == null || !pickedImageFile!.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Selected image file does not exist",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
        return; 
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered Successfully", style: TextStyle(fontSize: 20.0),)
        )
      );

      final storageRef = FirebaseStorage.instance.ref()
            .child('users')
            .child(userCredential.user!.uid);

      await storageRef.putFile(pickedImageFile!);
      final downloadImgUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': name,
            'email': email,
            'imageUrl': downloadImgUrl,
          });

      Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => const MapScreen())
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Password Provided is too Weak",
              style: TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Account Already exists",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      pickImage();
                    },
                    child: Stack(
                      children: [
                        Container(
                          child: pickedImageFile == null
                              ? const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 50,
                                  child: Icon(Icons.account_circle,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(pickedImageFile!),
                                  radius: 50,
                                ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Full Name',
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person, color: Colors.blue,),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Email";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Email',
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Colors.blue,),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter Password";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter Password',
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue,),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.blue,),
                      )
                    ),
                    obscureText: !isVisible,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async{
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          name= nameController.text;
                          email= emailController.text;
                          password=passwordController.text;
                        });
                        await signUp();
                      }
                      setState(() {
                        isLoading = !isLoading;
                      });
                    }, 
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.4)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                    child:  isLoading
                          ? const CircularProgressIndicator(color: Colors.white,)
                          : const Text("SignUp", style: TextStyle(fontSize: 16))
                  ),

                  //Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                        child: const Text("LogIn")
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}