import 'package:carcount/components/text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Usuarios");

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  Future<void> removeContact(String contactEmail) async {
    await usersCollection.doc(currentUser.email).update({
      'Contactos': FieldValue.arrayRemove([contactEmail])
    });
    await usersCollection.doc(contactEmail).update({
      'Contactos': FieldValue.arrayRemove([currentUser.email])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF2274A5),
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.person, size: 72, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: usersCollection.doc(currentUser.email).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> contactos = userData['Contactos'] ?? [];

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              'Información',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MyTextBox(
                          text: userData['Nombre de usuario'],
                          sectionName: 'Nombre de usuario',
                          onPressed: () {},
                        ),
                        MyTextBox(
                          text: userData['Coche'],
                          sectionName: 'Coche',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              onPressed: signOut,
                              child: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Text(
                              'Contactos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: contactos.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: usersCollection.doc(contactos[index]).get(),
                              builder: (context, contactSnapshot) {
                                if (contactSnapshot.hasData) {
                                  final contactData = contactSnapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(contactData['Nombre de usuario']),
                                    subtitle: Text(contactData['email']),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => removeContact(contactos[index]),
                                    ),
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            );
                          },
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
