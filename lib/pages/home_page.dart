import 'package:carcount/components/drawer.dart';
import 'package:carcount/components/groups.dart';
import 'package:carcount/pages/create_group_page.dart';
import 'package:carcount/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Usuario actual
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Cerrar sesión
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Navegar a la página de creación de grupos
  Future<void> goToCreateGroupPage() async {
    // Esperar a que se cree un grupo y actualizar la pantalla
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupPage(),
      ),
    );
    setState(() {}); // Actualizar la lista de grupos
  }

  // Ir a la página de perfil
  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Grupos", style: TextStyle(color: Colors.white)),
      ),
      drawer: MyDrawer(onProfileTap: goToProfilePage),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Lista de grupos
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Usuarios")
                    .doc(currentUser.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                    return const Center(child: Text("No hay grupos disponibles"));
                  }

                  // Obtener la lista de grupos del usuario
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final userGroups = userData['Grupos'] ?? [];

                  if (userGroups.isEmpty) {
                    return const Center(child: Text("No perteneces a ningún grupo"));
                  }

                  return ListView.builder(
                    itemCount: userGroups.length,
                    itemBuilder: (context, index) {
                      
                      final group = userGroups[index];
                      return Groups(
                        name: group['Name'],
                        groupId: group['GroupId'],
                      );
                    },
                  );
                },
              ),
            ),

            // Botón para crear grupo (sin el TextField)
            IconButton(
              onPressed: goToCreateGroupPage,
              icon: const Icon(
                Icons.add_circle, 
                size: 50,
                color: Color(0xFF2274A5),),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
