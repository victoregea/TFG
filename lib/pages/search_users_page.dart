import 'package:carcount/pages/user_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2274A5),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text(
          "Buscar usuarios",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Color del fondo
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Curvatura superior izquierda
            topRight: Radius.circular(30), // Curvatura superior derecha
          ),
        ),
        child: Column(
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Buscar usuario',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
        
            // Resultados de la busqueda
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Usuarios').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
        
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No hay usuarios disponibles'));
                  }
        
                  // Filtrar usuarios según la busqueda
                  final filteredUsers = snapshot.data!.docs
                    .where((user) {
                      final userData = user.data() as Map<String, dynamic>;
                      final userName = userData['Nombre de usuario'].toString().toLowerCase();
                      final userEmail = userData['email'];

                      // Excluir al usuario actual y aplicar filtro por nombre
                      return userEmail != currentUserEmail && userName.contains(searchQuery);
                    })
                    .toList();
        
                  if (filteredUsers.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron resultados'));
                  }
        
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        title: Text(user['Nombre de usuario']),
                        subtitle: Text(user['email']),
                        leading: const Icon(Icons.person),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(userEmail: user['email']),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
