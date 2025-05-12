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
  List<String> selectedContacts = [];

  // Función para obtener información de los contactos
  Future<List<Map<String, dynamic>>> getContactsInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection("Usuarios")
        .doc(currentUser.email)
        .get();

    if (!doc.exists) return [];

    final userData = doc.data();
    final List<dynamic> contactEmails = userData?['Contactos'] ?? [];

    List<Map<String, dynamic>> contactsList = [];

    for (String email in contactEmails) {
      final contactDoc = await FirebaseFirestore.instance
          .collection("Usuarios")
          .doc(email)
          .get();
      if (contactDoc.exists) {
        contactsList.add(contactDoc.data() as Map<String, dynamic>);
      }
    }
    return contactsList;
  }

  // Crear grupo con contactos seleccionados
  Future<void> createGroup() async {
    if (textController.text.isNotEmpty && selectedContacts.isNotEmpty) {
      try {
        DocumentReference groupRef =
            await FirebaseFirestore.instance.collection("Grupos").add({
          'Name': textController.text,
          'Admin': currentUser.email,
          'Participants': [currentUser.email, ...selectedContacts],
          'TimeStamp': Timestamp.now(),
        });

        // Añadir el grupo al documento del usuario y sus contactos
        for (String contact in [currentUser.email!, ...selectedContacts]) {
          await FirebaseFirestore.instance
              .collection("Usuarios")
              .doc(contact)
              .update({
            'Grupos': FieldValue.arrayUnion([
              {
                'GroupId': groupRef.id,
                'Name': textController.text,
              }
            ])
          });
        }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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

              // Muestra los contactos seleccionados arriba de la lista
              // Muestra los contactos seleccionados en una fila desplazable
              if (selectedContacts.isNotEmpty) ...[
                const Text(
                  "Contactos seleccionados:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Contenedor deslizable horizontalmente
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: selectedContacts.map((email) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Chip(
                          label: Text(email),
                          backgroundColor: Colors.blue[200],
                          deleteIcon:
                              const Icon(Icons.close, color: Colors.white),
                          onDeleted: () {
                            setState(() {
                              selectedContacts.remove(email);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
              ],

              const Text(
                "Añadir contactos",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Caja con la lista de contactos
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getContactsInfo(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final contacts = snapshot.data!;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final email =
                              contact['email'] ?? 'Correo desconocido';
                          final name =
                              contact['Nombre de usuario'] ?? 'Desconocido';
                          final isSelected = selectedContacts.contains(email);

                          return ListTile(
                            title: Text(name),
                            subtitle: Text(email),
                            trailing: Checkbox(
                              value: isSelected,
                              activeColor:
                                  const Color(0xFF2274A5), 
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedContacts.add(email);
                                  } else {
                                    selectedContacts.remove(email);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2274A5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child:
                    const Text("Crear Grupo", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
