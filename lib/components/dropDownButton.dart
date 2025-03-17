import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyDropButton extends StatefulWidget {
  final String hintText;
  final Function(String)
      onCarSelected; // Callback para devolver el coche seleccionado

  const MyDropButton({
    super.key,
    required this.hintText,
    required this.onCarSelected,
  });

  @override
  State<MyDropButton> createState() => _MyDropButtonState();
}

class _MyDropButtonState extends State<MyDropButton> {
  String? selectedCar; // Aquí guardaremos el coche seleccionado

  @override
  Widget build(BuildContext context) {
    List<String> listaDeCoches = ['BMW', 'Mercedes', 'Toyota', 'Seat'];

    return DropdownButtonFormField<String>(
      value: selectedCar, // Valor actual
      items: listaDeCoches.map((car) {
        return DropdownMenuItem(
          value: car,
          child: Text(car),
        );
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedCar = value; // Actualiza el valor seleccionado
        });

        widget.onCarSelected(
            value!); // Llama al callback con el coche seleccionado
      },

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.time_to_leave_sharp, color: Colors.grey),
        hintText: 'Seleccione un coche',
        filled: true,
        fillColor: Colors.grey[350],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
