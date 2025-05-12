import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final String userEmail;
  const UserProfilePage({super.key, required this.userEmail});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isContact = false;

  @override
  void initState() {
    super.initState();
    checkIfContact();
  }

  // Verifica si el usuario ya es un contacto
  Future<void> checkIfContact() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(currentUser.email)
        .get();

    List<dynamic> contacts = userDoc["Contactos"] ?? [];

    setState(() {
      isContact = contacts.contains(widget.userEmail);
    });
  }

  // Añadir o quitar contacto
  Future<void> toggleContact() async {
    DocumentReference currentUserRef = FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(currentUser.email);

    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection("Usuarios").doc(widget.userEmail);

    if (isContact) {
      await currentUserRef.update({
        "Contactos": FieldValue.arrayRemove([widget.userEmail])
      });
      await otherUserRef.update({
        "Contactos": FieldValue.arrayRemove([currentUser.email])
      });
    } else {
      await currentUserRef.update({
        "Contactos": FieldValue.arrayUnion([widget.userEmail])
      });
      await otherUserRef.update({
        "Contactos": FieldValue.arrayUnion([currentUser.email])
      });
    }

    setState(() {
      isContact = !isContact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Perfil de usuario",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2274A5),
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.person, size: 72, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  widget.userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: toggleContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isContact ? Colors.grey : Colors.white70, // Color dinámico
                    foregroundColor: Colors.black, // Texto en blanco
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(25), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    isContact ? "Quitar de contactos" : "Añadir a contactos",
                    style: const TextStyle(fontSize: 16),
                  ),
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
                stream: FirebaseFirestore.instance
                    .collection("Usuarios")
                    .doc(widget.userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

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
                        infoContainer(
                            "Nombre de usuario", userData['Nombre de usuario']),
                        infoContainer("Coche", userData['Coche']),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar el perfil: ${snapshot.error}'));
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

  Widget infoContainer(String title, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
