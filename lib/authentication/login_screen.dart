import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ict_app/authentication/signup_screen.dart';
import 'package:ict_app/screens/tabs_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = false;
  bool isLoading = false;

  String email = "", password = "";

  login(email, password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => const TabsScreen())
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
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
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade50,
                    ),
                    child: Image.asset(
                      "assets/login.png",
                    ),
                  ),
                  const SizedBox(height: 50),
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
                        // setState(() {
                        //   email= emailController.text;
                        //   password=passwordController.text;
                        // });
                        await login(emailController.text, passwordController.text);
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
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    child:  isLoading
                          ? const CircularProgressIndicator(color: Colors.white,)
                          : const Text("Login", style: TextStyle(fontSize: 16))
                  ),

                  //Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                        },
                        child: const Text("SignUp")
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