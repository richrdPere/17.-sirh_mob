import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/Peligro.dart';

class InsertarPeligro extends StatefulWidget {
  const InsertarPeligro({super.key});

  @override
  State<InsertarPeligro> createState() => _InsertarPeligroState();
}

class _InsertarPeligroState extends State<InsertarPeligro> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Otras instancias
  List<Peligro> _allPeligros = [];
  bool _isLoading = true;

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _gravedadController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();

  DateTime? _fechaSeleccionada;

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshPeligro();
  }

  // 5.- Funciones
  // Función para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha inicial
      firstDate: DateTime(2000), // Fecha mínima
      lastDate: DateTime(2100), // Fecha máxima
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(fecha);
      });
    }
  }

  // Obtener
  void _refreshPeligro() async {
    final data = await db.getPeligros();

    setState(() {
      _allPeligros = data;
      _isLoading = false;
    });
  }

  // Insertar
  Future<void> _addPeligro() async {
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor selecciona una fecha.")),
      );
      return;
    }

    await db.insertPeligro(
      Peligro(
        puestoTrabajoId: null,
        tareaId: null,
        nombre: _nombreController.text,
        ruta: _imagenController.text,
        gravedad: _gravedadController.text,
        std: _stdController.text,
        fechaIdentificacion: _fechaSeleccionada!,
        usuarioCreacion: 'admin',
        usuarioModificacion: '',
        fechaCreacion: DateTime.now(),
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPeligro();
  }

  // Actualizar
  Future<void> _updatePasosTarea(int id) async {
    await db.updatePeligro(
      Peligro(
        id: id,
        puestoTrabajoId: null,
        tareaId: null,
        nombre: _nombreController.text,
        gravedad: _gravedadController.text,
        fechaIdentificacion: _fechaSeleccionada!,
        ruta: _imagenController.text,
        std: _stdController.text,
        usuarioCreacion: 'system', //  ficticio
        fechaCreacion: DateTime(2025, 01, 01), //  ficticio
        usuarioModificacion: 'admin_update', //  ficticio para update
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPeligro();
  }

  // Eliminar
  void _deletePasosTarea(int id) async {
    await db.deletePeligro(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Peligro Eliminado."),
      ),
    );
    _refreshPeligro();
  }

  // 6.- Form Tarea
  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = _allPeligros.firstWhere((e) => e.id == id);
      _nombreController.text = existingData.nombre;
      _gravedadController.text = existingData.gravedad;
      _fechaController.text = existingData.fechaIdentificacion.toString();
      _imagenController.text = existingData.ruta.toString();
      _stdController.text = existingData.std.toString();
    }

    //   showModalBottomSheet(
    //     elevation: 5,
    //     isScrollControlled: true,
    //     context: context,
    //     builder: (_) => Container(
    //       padding: EdgeInsets.only(
    //         top: 30,
    //         left: 15,
    //         right: 15,
    //         bottom: MediaQuery.of(context).viewInsets.bottom + 50,
    //       ),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.end,
    //         children: [
    //           TextField(
    //             controller: _nombreController,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Nombre",
    //             ),
    //           ),
    //           SizedBox(height: 10),
    //           TextField(
    //             controller: _tipoController,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Tipo",
    //             ),
    //           ),
    //           SizedBox(height: 10),
    //           TextField(
    //             controller: _pasosController,
    //             maxLines: 3,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Pasos",
    //             ),
    //           ),
    //           SizedBox(height: 10),
    //           TextField(
    //             controller: _frecuenciaController,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Frecuencias",
    //             ),
    //           ),
    //           SizedBox(height: 10),
    //           TextField(
    //             controller: _stdController,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Estado std",
    //             ),
    //           ),
    //           SizedBox(height: 10),
    //           Center(
    //             child: ElevatedButton(
    //               onPressed: () async {
    //                 if (id == null) {
    //                   await _addPasosTarea();
    //                 }

    //                 if (id != null) {
    //                   await _updatePasosTarea(id);
    //                 }

    //                 _nombreController.text = "";
    //                 _tipoController.text = "";
    //                 _frecuenciaController.text = "";
    //                 _pasosController.text = "";
    //                 _stdController.text = "";

    //                 // Ocultar Bottom sheet
    //                 Navigator.of(context).pop();
    //                 print("Agregar Tarea");
    //               },
    //               child: Padding(
    //                 padding: EdgeInsets.all(18),
    //                 child: Text(
    //                   id == null ? "Agregar Tarea" : "Actualizar Tarea",
    //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // @override
    // Widget build(BuildContext context) {
    //   return Scaffold(
    //     backgroundColor: const Color(0xFFECEAF4),
    //     appBar: AppBar(title: const Text("Agregar Puestos")),
    //     body: _isLoading
    //         ? Center(child: CircularProgressIndicator())
    //         : ListView.builder(
    //             itemCount: _allTareas.length,
    //             itemBuilder: (context, index) {
    //               final puesto = _allTareas[index];
    //               return Card(
    //                 margin: EdgeInsets.all(15),
    //                 child: ListTile(
    //                   title: Padding(
    //                     padding: EdgeInsets.symmetric(vertical: 5),
    //                     child: Text(puesto.pasos, style: TextStyle(fontSize: 20)),
    //                   ),
    //                   subtitle: Text("Tarea: ${puesto.nombre}"),
    //                   trailing: Row(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       IconButton(
    //                         icon: Icon(Icons.edit, color: Colors.blue),
    //                         onPressed: () => showBottomSheet(puesto.id),
    //                       ),
    //                       IconButton(
    //                         icon: Icon(Icons.delete, color: Colors.red),
    //                         onPressed: () => _deletePasosTarea(puesto.id!),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               );
    //             },
    //           ),
    //     floatingActionButton: FloatingActionButton(
    //       onPressed: () => showBottomSheet(null),
    //       child: Icon(Icons.add),
    //     ),
    //   );
  }
}
