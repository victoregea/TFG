import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:carcount/components/dropDownButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();
  final userNameController = TextEditingController();
  List<Map<String, dynamic>> cars = [];
  String? selectedCar;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    String jsonString = await rootBundle.loadString('assets/cars.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      cars = jsonData.cast<Map<String, dynamic>>();
    });
  }

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      displayMessage("Las contraseñas no coinciden");
      return;
    }

    if (selectedCar == null) {
      Navigator.pop(context);
      displayMessage("Selecciona un coche");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      FirebaseFirestore.instance
          .collection("Usuarios")
          .doc(userCredential.user!.email)
          .set({
        'Nombre de usuario': userNameController.text,
        'Coche': selectedCar,
        'email': emailTextController.text,
        'Contactos': []
      });

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      displayMessage(e.toString());
    }
  }

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
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2274A5), Color(0xFF2274A5)],
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
                const Text(
                  "Crear cuenta",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: userNameController,
                  decoration: _inputDecoration("Nombre de usuario", Icons.person),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailTextController,
                  decoration: _inputDecoration("Correo electrónico", Icons.email),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordTextController,
                  obscureText: true,
                  decoration: _inputDecoration("Contraseña", Icons.lock),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordTextController,
                  obscureText: true,
                  decoration: _inputDecoration("Confirmar contraseña", Icons.lock),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Selecciona un coche", Icons.directions_car),
                  value: selectedCar,
                  items: cars.map((car) {
                    return DropdownMenuItem<String>(
                      value: car["modelo"],
                      child: Text(car["modelo"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCar = value;
                    });
                  },
                ),
                const SizedBox(height: 15),
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
                    child: const Text("Registrarse", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 15),
                const Text("¿Ya tienes una cuenta?", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: widget.onTap,
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(color: Color(0xFF2274A5), fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[350],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
    );
  }
}