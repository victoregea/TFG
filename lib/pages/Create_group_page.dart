import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Función para crear el grupo
  Future<void> createGroup() async {
    if (textController.text.isNotEmpty) {
      try {
        DocumentReference groupRef =
            await FirebaseFirestore.instance.collection("Grupos").add({
          'Name': textController.text,
          'UserEmail': currentUser.email,
          'TimeStamp': Timestamp.now(),
        });

        // Añadir el grupo al documento del usuario
        await FirebaseFirestore.instance
            .collection("Usuarios")
            .doc(currentUser.email)
            .update({
          'Grupos': FieldValue.arrayUnion([
            {
              'GroupId': groupRef.id,
              'Name': textController.text,
            }
          ])
        });

        // Volver a la pantalla anterior
        Navigator.pop(context);
      } catch (e) {
        print("Error al crear grupo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Crear grupo", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Nombre del grupo
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Nombre del grupo',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón para crear el grupo
              ElevatedButton(
                onPressed: createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2274A5), // Color de fondo azul
                  foregroundColor: Colors.white, // Texto en color blanco
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordes redondeados
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Tamaño del botón
                ),
                child: const Text(
                  "Crear Grupo",
                  style: TextStyle(fontSize: 16), // Tamaño del texto
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
