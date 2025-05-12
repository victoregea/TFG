import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTripPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const CreateTripPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedConductor;
  List<String> selectedPassengers = [];
  DateTime selectedDate = DateTime.now();
  double kilometers = 0;
  double calculatedCost = 0;
  String title = "";

  Map<String, dynamic> usersInGroup = {};
  Map<String, dynamic> carsData = {};

  @override
  void initState() {
    super.initState();
    loadUsersInGroup();
    loadCarData();
  }

  Future<void> loadUsersInGroup() async {
    final snapshot = await FirebaseFirestore.instance.collection("Usuarios").get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final grupos = List.from(data['Grupos'] ?? []);

      final pertenece = grupos.any((g) => g['GroupId'] == widget.groupId);
      if (pertenece) {
        usersInGroup[doc.id] = data;
      }
    }

    setState(() {});
  }

  Future<void> loadCarData() async {
    final String jsonString = await rootBundle.loadString('assets/cars.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    for (var car in jsonData) {
      carsData[car['modelo']] = car;
    }
  }

  void calculateCost() {
    if (selectedConductor != null) {
      final userData = usersInGroup[selectedConductor];
      final modelo = userData['Coche'];
      final carInfo = carsData[modelo];
      if (carInfo != null) {
        final minimo = carInfo['minimo'] ?? 0;
        setState(() {
          calculatedCost = kilometers * minimo;
        });
      }
    }
  }

  Future<void> saveTrip() async {
    if (!_formKey.currentState!.validate() || selectedConductor == null || selectedPassengers.isEmpty) return;

    final tripData = {
      "titulo": title,
      "conductor": selectedConductor,
      "fecha": selectedDate.toIso8601String(),
      "pasajeros": selectedPassengers,
      "km": kilometers,
      "coste": calculatedCost,
    };

    await FirebaseFirestore.instance
        .collection("Grupos")
        .doc(widget.groupId)
        .collection("Trayectos")
        .add(tripData);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2274A5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2274A5),
        title: const Text('Crear Trayecto', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: usersInGroup.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Título del trayecto'),
                        onChanged: (val) => title = val,
                        validator: (val) => val == null || val.isEmpty ? 'Introduce un título' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Conductor'),
                        value: selectedConductor,
                        items: usersInGroup.keys
                            .map((email) => DropdownMenuItem(
                                  value: email,
                                  child: Text(usersInGroup[email]['Nombre de usuario'] ?? email),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedConductor = value;
                            calculateCost();
                          });
                        },
                        validator: (val) => val == null ? 'Selecciona un conductor' : null,
                      ),
                      const SizedBox(height: 20),
                      const Text("Pasajeros", style: TextStyle(fontWeight: FontWeight.bold)),
                      Column(
                        children: usersInGroup.keys.map((email) {
                          final username = usersInGroup[email]['Nombre de usuario'] ?? email;
                          return CheckboxListTile(
                            title: Text(username),
                            value: selectedPassengers.contains(email),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedPassengers.add(email);
                                } else {
                                  selectedPassengers.remove(email);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text("Fecha del trayecto"),
                        subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Kilómetros'),
                        onChanged: (val) {
                          kilometers = double.tryParse(val) ?? 0;
                          calculateCost();
                        },
                      ),
                      const SizedBox(height: 20),
                      Text("Coste estimado: ${calculatedCost.toStringAsFixed(2)} €",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2274A5)),
                        onPressed: saveTrip,
                        child: const Text("Guardar Trayecto", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
