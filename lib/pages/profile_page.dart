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
  // Usuario
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Todos los usuarios
  final usersCollection = FirebaseFirestore.instance.collection("Usuarios");

  // Editar nombre
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[700],
        title: Text(
          "Editar $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style:
              const TextStyle(color: Colors.white), // Texto ingresado en blanco
          cursorColor: Colors.white, // Barrita del cursor en blanco
          decoration: InputDecoration(
            labelText: 'Nuevo $field',
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.person, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          TextButton(
            child: Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // Actualizar en firestore
    if (newValue.trim().length > 0) {
      // Solo se actualiza si hay algo escrito
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  // Editar coche
  Future<void> editFieldCoche(String field) async {
    String? selectedCar; // Valor seleccionado

    List<String> listaDeCoches = ['BMW', 'Mercedes', 'Toyota', 'Seat'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[700],
        title: Text(
          "Editar $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: DropdownButtonFormField<String>(
          value: selectedCar,
          dropdownColor: Colors.grey[800], 
          style: const TextStyle(
              color: Colors.white), 
          iconEnabledColor: Colors.white, 
          decoration: InputDecoration(
            labelText: 'Selecciona un coche',
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon:
                const Icon(Icons.time_to_leave_sharp, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          items: listaDeCoches.map((car) {
            return DropdownMenuItem(
              value: car,
              child: Text(car),
            );
          }).toList(),
          onChanged: (value) {
            selectedCar = value; // Actualiza el valor seleccionado
          },
        ),
        actions: [
          TextButton(
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),

          TextButton(
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (selectedCar != null) {
                Navigator.of(context).pop(selectedCar);
              }
            },
          ),
        ],
      ),
    );

    
    if (selectedCar != null && selectedCar!.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: selectedCar});
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
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
        centerTitle: true, // Centra el título perfectamente
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Sección superior (Icono y Email) con fondo azul
          Container(
            color: Color(0xFF2274A5),
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.person,
                    size: 72, color: Colors.white), // Icono en blanco
                const SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18), // Texto en blanco
                ),
              ],
            ),
          ),

          // Sección inferior (Información y Cerrar Sesión)
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
                    .doc(currentUser.email)
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

                        MyTextBox(
                          text: userData['Nombre de usuario'],
                          sectionName: 'Nombre de usuario',
                          onPressed: () => editField('Nombre de usuario'),
                        ),

                        MyTextBox(
                          text: userData['Coche'],
                          sectionName: 'Coche',
                          onPressed: () => editFieldCoche('Coche'),
                        ),

                        // Tarjeta de Información
                        const SizedBox(height: 20),

                        // Botón de Cerrar Sesión
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
