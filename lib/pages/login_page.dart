import 'package:carcount/components/button.dart';
import 'package:carcount/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores de texto (email y contraseña)
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // Iniciar sesión
  void signIn() async {
    // circulo de carga
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Quitar el circulo de carga
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
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
    return Scaffold(
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
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 245),
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
              const SizedBox(height: 0),

              // welcome back
              Text(
                "C A R C O U N T",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF2274A5),
                ),
              ),

              const SizedBox(height: 40),

              // email textfiel
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

              const SizedBox(height: 15),

              // sign in button
              /*MyButton(
                onTap: signIn, 
                text: "Iniciar sesión",
              ),*/

              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2274A5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: signIn,
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              // go to register page

              TextButton(
                onPressed: widget.onTap,
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    color: Color(0xFF2274A5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )

              /*Row(
                children: [
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Crear una cuenta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2.0,
                      ),
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ),
    ));
  }
}
