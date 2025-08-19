import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GestionIncidenciasScreen extends StatefulWidget {
  const GestionIncidenciasScreen({super.key});

  @override
  State<GestionIncidenciasScreen> createState() =>
      _GestionIncidenciasScreenState();
}

class _GestionIncidenciasScreenState extends State<GestionIncidenciasScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final codigoController = TextEditingController();
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final tipoController = TextEditingController();
  final categoriaController = TextEditingController();
  final probabilidadController = TextEditingController();
  final consecuenciaController = TextEditingController();
  final nivelController = TextEditingController();
  final controlesActualesController = TextEditingController();
  final controlesRequeridosController = TextEditingController();
  final prioridadController = TextEditingController();
  final plazoControlController = TextEditingController();
  final estadoController = TextEditingController(text: "Pendiente");
  final responsableController = TextEditingController();
  final tipoImpactoController = TextEditingController();

  // Valores numéricos
  int areaMetaId = 0;
  int metaId = 0;
  int puesto = 0;
  int valoracion = 0;
  int impactoAmbiental = 0;
  int cumpleEca = 0;

  // Fechas
  DateTime fechaIdentificacion = DateTime.now();
  DateTime fechaUltimaRevision = DateTime.now();

  // Formato fecha
  String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  void _guardarRiesgo() {
    if (_formKey.currentState!.validate()) {
      final riesgo = {
        "codigo": codigoController.text,
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
        "fechaIdentificacion": formatDate(fechaIdentificacion),
        "areaMetaId": areaMetaId,
        "metaId": metaId,
        "puesto": puesto,
        "tipo": tipoController.text,
        "categoria": categoriaController.text,
        "probabilidad": probabilidadController.text,
        "consecuencia": consecuenciaController.text,
        "nivel": nivelController.text,
        "valoracion": valoracion,
        "controlesActuales": controlesActualesController.text,
        "controlesRequeridos": controlesRequeridosController.text,
        "prioridad": prioridadController.text,
        "plazoControl": plazoControlController.text,
        "estado": estadoController.text,
        "fechaUltimaRevision": formatDate(fechaUltimaRevision),
        "responsable": responsableController.text,
        "impactoAmbiental": impactoAmbiental,
        "tipoImpacto": tipoImpactoController.text,
        "cumpleEca": cumpleEca,
      };

      print("Datos listos para enviar: $riesgo");

      // Aquí iría la llamada al backend con POST
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Riesgo guardado correctamente")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? Colors.blueGrey : Colors.blue;
    // final Color secondaryColor = isDarkMode ? Colors.greenAccent : Colors.green;

    // final gps = currentPosition;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riesgo - SSOMMA',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
              // );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(codigoController, "Código"),
              _buildTextField(nombreController, "Nombre"),
              _buildTextField(
                descripcionController,
                "Descripción",
                maxLines: 3,
              ),
              _buildDatePicker("Fecha Identificación", fechaIdentificacion, (
                date,
              ) {
                setState(() => fechaIdentificacion = date);
              }),
              _buildNumberField("Area Meta ID", (val) => areaMetaId = val),
              _buildNumberField("Meta ID", (val) => metaId = val),
              _buildNumberField("Puesto", (val) => puesto = val),
              _buildTextField(tipoController, "Tipo"),
              _buildTextField(categoriaController, "Categoría"),
              _buildTextField(probabilidadController, "Probabilidad"),
              _buildTextField(consecuenciaController, "Consecuencia"),
              _buildTextField(nivelController, "Nivel"),
              _buildNumberField("Valoración", (val) => valoracion = val),
              _buildTextField(
                controlesActualesController,
                "Controles Actuales",
              ),
              _buildTextField(
                controlesRequeridosController,
                "Controles Requeridos",
              ),
              _buildTextField(prioridadController, "Prioridad"),
              _buildTextField(plazoControlController, "Plazo Control"),
              _buildTextField(estadoController, "Estado"),
              _buildDatePicker("Fecha Última Revisión", fechaUltimaRevision, (
                date,
              ) {
                setState(() => fechaUltimaRevision = date);
              }),
              _buildTextField(responsableController, "Responsable"),
              _buildNumberField(
                "Impacto Ambiental",
                (val) => impactoAmbiental = val,
              ),
              _buildTextField(tipoImpactoController, "Tipo Impacto"),
              _buildNumberField("Cumple ECA", (val) => cumpleEca = val),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarRiesgo,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? "Campo requerido" : null,
      ),
    );
  }

  Widget _buildNumberField(String label, Function(int) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => onSaved(int.tryParse(value) ?? 0),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(formatDate(date)),
        ),
      ),
    );
  }
}
