import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String userEmail;
  const UserProfilePage({super.key, required this.userEmail});

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
          // Sección superior (Icono y Email) con fondo azul
          Container(
            color: const Color(0xFF2274A5),
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.person, size: 72, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18), // Texto en blanco
                ),
              ],
            ),
          ),
          // Sección inferior (Información sin edición)
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
                    .doc(userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      children: [
                        // Título "Información"
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

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 15,
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nombre de usuario',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userData['Nombre de usuario'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.only(
                            left: 15,
                            bottom: 15,
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Coche',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),
                              Text(
                                userData['Coche'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

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
}
