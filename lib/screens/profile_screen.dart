import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ict_app/screens/form_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.exists) {

            final user = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['imageUrl']),
                    ),
                    title: Text(user['Name'] ?? 'name'),
                    subtitle: Text(user['username']),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blue,),
                    onTap: () {

                    },
                  ),
                ),
                const SizedBox(height: 1,),
                Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Column(
                    children: [
                      const Divider(
                        height: 10,
                        color: Colors.grey,
                        thickness: 2,
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range, color: Colors.blue,),
                        title: const Text("Financial Year",
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(user['Financial Year'] ?? 'year',
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: (){},                   
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 50, right: 10),
                        child: Divider(
                          height: 10,
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.blue,),
                        title: const Text(
                          "Address",
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(user['Address'] ?? 'address',
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: ()
                        {
                          
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 50, right: 10),
                        child: Divider(
                          height: 10,
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.blue,),
                        title: const Text(
                          "Email",
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(user["email"],
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: ()
                        {
                          
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 50, right: 10),
                        child: Divider(
                          height: 10,
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.water, color: Colors.blue,),
                        title: const Text("Water Supply Source",
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(user['Water Supply Source'] ?? 'source',
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: (){},                   
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 50, right: 10),
                        child: Divider(
                          height: 10,
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit_document, color: Colors.blue,),
                        title: const Text(
                          "Update Form",
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FormScreen()));
                        },
                      ),
                      const Divider(
                        height: 10,
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          } else {
            return const Center(child: Text('No user data found.'));
          }
        },
      ),
    );
  }
}
