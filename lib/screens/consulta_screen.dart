import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultaScreen extends StatefulWidget {
  const ConsultaScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConsultaScreenState createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends State<ConsultaScreen> {
  String nombreMedicamento = ''; // Variable para almacenar el nombre del medicamento
  bool escaso = false; // Variable para indicar si el medicamento está escaso
  bool mostrarResultado = false; // Variable para mostrar el resultado solo después de consultar

  Future<void> consultarMedicamento() async {
    var url = Uri.parse('https://datos.gov.co/resource/sdmr-tfmf.json');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Lógica para verificar si el medicamento está escaso
      var medicamento = data.firstWhere((med) =>
          med['nombre_comercial_']
              .toString()
              .toUpperCase()
              .contains(nombreMedicamento.toUpperCase()));
      int cantidadDisponible = int.parse(medicamento['cantidad_solicitada']);

      setState(() {
        escaso = cantidadDisponible > 30;
        mostrarResultado = true; // Mostrar el resultado después de consultar
      });
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.medical_services),
        title: const Center(child: Text('Consulta de Medicamento')),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  nombreMedicamento = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Nombre del medicamento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    consultarMedicamento();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Añade el color azul al botón
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, // Hace la letra negrita
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Añade un borde redondeado al botón
                      side: const BorderSide(color: Colors.black), // Añade un borde negro al botón
                    ),
                  ),
                  child: const Text('Consultar', style: TextStyle(color: Colors.black),),
                ),
              const SizedBox(height: 20),
              mostrarResultado
                  ? Text(
                      escaso
                          ? 'El medicamento está escaso'
                          : 'El medicamento no está escaso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: escaso ? Colors.red : Colors.green,
                      ),
                    )
                  : Container(), // No mostrar el mensaje hasta después de consultar
            ],
          ),
        ),
      ),
    );
  }
}
