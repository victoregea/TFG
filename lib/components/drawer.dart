import 'package:carcount/components/my_list_tile.dart';
import 'package:carcount/pages/search_users_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
  });

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF2274A5),
      child: Column(
        children: [

          //Header
          DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            ),
          ),

          // Lista de paginas
          MyListTile(
            icon: Icons.home, 
            text: 'Grupos',
            onTap: () => Navigator.pop(context),
          ),

          MyListTile(
            icon: Icons.person, 
            text: 'Perfil', 
            onTap: onProfileTap,
          ),

          MyListTile(
            icon: Icons.search, 
            text: 'Buscar personas', 
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchUsersPage()),
              );
            },
          ),

          const SizedBox(height: 400),

          MyListTile(
            icon: Icons.logout, 
            text: 'Cerrar sesión', 
            onTap: signOut,
          ),



        ],
      ),
    );
  }
}