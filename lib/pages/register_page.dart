import 'package:carcount/components/dropDownButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  final userNameController = TextEditingController();
  final carController = TextEditingController();
  String? selectedCar;

  // Registrar usuario
  void signUp() async {
    // Circulo de carga
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Comprobar contraseña
    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      displayMessage("Las contraseñas no coinciden");
      return;
    }

    try {
      // Crear un usuario
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      // Crear un nuevo doc en firestore despues de crear un usuario
      FirebaseFirestore.instance
          .collection("Usuarios")
          .doc(userCredential.user!.email)
          .set({
        'Nombre de usuario': userNameController.text, // Nombre inicial
        'Coche': selectedCar,
        'email': emailTextController.text, // Coche inicial
      });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }

    // Añadir los datos de ususario
  }

  Future addUserDetails(String userName, String car, String email) async {
    await FirebaseFirestore.instance.collection('Usuarios').add({
      'Nombre de usuario': userName,
      'Coche': car,
      'email': email,
    });
  }

  // Mensaje de error
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List listaDeCoches = ['BMW', 'Mercedes', 'Toyota', 'Seat'];

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2274A5),
                Color(0xFF2274A5),
              ],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 110),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Nombre de usuario textfiel
                  /*MyTextField(
                      controller: userNameController,
                      hintText: 'Escribe un nombre de usuario',
                      obscureText: false),*/

                  TextField(
                    controller: userNameController,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      hintText: 'Nombre de usuario',
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // email textfiel
                  /*MyTextField(
                      controller: emailTextController,
                      hintText: 'Escribe tu Email',
                      obscureText: false),*/

                  TextField(
                    controller: emailTextController,
                    obscureText: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      hintText: 'Correo electrónico',
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // password
                  /*MyTextField(
                    controller: passwordTextController,
                    hintText: 'Escribe tu contraseña',
                    obscureText: true,
                  ),*/

                  TextField(
                    controller: passwordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      hintText: 'Contraseña',
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // confirm password
                  /*MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: 'Escribe de nuevo la contraseña',
                    obscureText: true,
                  ),*/

                  TextField(
                    controller: confirmPasswordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      hintText: 'Confirmar contraseña',
                      filled: true,
                      fillColor: Colors.grey[350],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Nombre de usuario textfiel
                  /*MyTextField(
                      controller: carController,
                      hintText: 'Selecciona un coche',
                      obscureText: false),*/

                  MyDropButton(
                    hintText: 'Selecciona un cccoche',
                    onCarSelected: (car) {
                      selectedCar = car; // Guardamos el coche seleccionado
                    },
                  ),

                  const SizedBox(height: 15),

                  // Boton registrarse
                  //MyButton(onTap: signUp, text: "Registrarse"),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2274A5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: signUp,
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(fontWeight: FontWeight.bold,)
                  ),

                  TextButton(
                    onPressed: widget.onTap,
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Color(0xFF2274A5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
