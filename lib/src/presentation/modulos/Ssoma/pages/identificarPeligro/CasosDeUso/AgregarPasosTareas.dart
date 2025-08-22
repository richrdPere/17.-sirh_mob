import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';

class AgregarPasosTareas extends StatefulWidget {
  const AgregarPasosTareas({super.key});

  @override
  State<AgregarPasosTareas> createState() => _AgregarPasosTareasState();
}

class _AgregarPasosTareasState extends State<AgregarPasosTareas> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todos los puestos
  List<Tarea> _allTareas = [];
  bool _isLoading = true;

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _pasosController = TextEditingController();
  final TextEditingController _frecuenciaController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshPasosTarea();
  }

  // 5.- Funciones
  // Obtener
  void _refreshPasosTarea() async {
    final data = await db.getPasosTarea();

    setState(() {
      _allTareas = data;
      _isLoading = false;
    });
  }

  // Insertar
  Future<void> _addPasosTarea() async {
    await db.insertPasosTarea(
      Tarea(
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        pasos: _pasosController.text,
        frecuencia: _frecuenciaController.text,
        std: _stdController.text,
        usuarioCreacion: 'admin',
        fechaCreacion: DateTime.now(),
        usuarioModificacion: '',
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPasosTarea();
  }

  // Actualizar
  Future<void> _updatePasosTarea(int id) async {
    await db.updatePasosTarea(
      Tarea(
        id: id,
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        pasos: _pasosController.text,
        frecuencia: _frecuenciaController.text,
        std: _stdController.text,
        usuarioCreacion: 'system', //  ficticio
        fechaCreacion: DateTime(2025, 01, 01), //  ficticio
        usuarioModificacion: 'admin_update', //  ficticio para update
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPasosTarea();
  }

  // Eliminar
  void _deletePasosTarea(int id) async {
    await db.deletePasosTarea(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Tarea Eliminado."),
      ),
    );
    _refreshPasosTarea();
  }

  // Formatear Fecha: Si es string
  String formatFechaHoraString(String fecha) {
    try {
      // 1. Limpiar la cadena y eliminar la parte extra de microsegundos
      final cleanDate = fecha.split('-').first; // "2025-08-19 17:03:18"

      // 2. Parsear la fecha original
      final dateTime = DateTime.parse(cleanDate);

      // 3. Formatear al formato deseado
      final formato = DateFormat('dd/MM/yyyy HH:mm');
      return formato.format(dateTime);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  // Formatear Fecha: Si es datetime
  String formatFechaHoraDate(DateTime fecha) {
    try {
      final formato = DateFormat('dd/MM/yyyy - HH:mm');
      return formato.format(fecha);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  // 6.- Form Tarea
  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = _allTareas.firstWhere((e) => e.id == id);
      _nombreController.text = existingData.nombre;
      _tipoController.text = existingData.tipo;
      _pasosController.text = existingData.pasos;
      _frecuenciaController.text = existingData.frecuencia;
      _stdController.text = existingData.std;
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombre",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tipoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tipo",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _pasosController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Pasos",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _frecuenciaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Frecuencias",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _stdController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Estado std",
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addPasosTarea();
                  }

                  if (id != null) {
                    await _updatePasosTarea(id);
                  }

                  _nombreController.text = "";
                  _tipoController.text = "";
                  _frecuenciaController.text = "";
                  _pasosController.text = "";
                  _stdController.text = "";

                  // Ocultar Bottom sheet
                  Navigator.of(context).pop(true);
                  print("Agregar Tarea");
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Tarea" : "Actualizar Tarea",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(title: const Text("Agregar Puestos")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allTareas.length,
              itemBuilder: (context, index) {
                final tarea = _allTareas[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // margin: EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título principal (nombre del puesto)
                        Text(
                          "${tarea.id}.- Puesto: ${tarea.nombre}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // color: Color(0xFF1E88E5),
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Meta y STD en una fila
                        Row(
                          children: [
                            Icon(
                              Icons.apartment,
                              color: Colors.blueGrey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Tipo: ${tarea.tipo}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.fact_check,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "STD: ${tarea.std}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Pasos
                        Text(
                          tarea.pasos.isNotEmpty
                              ? "Paso Tarea: ${tarea.pasos}"
                              : "Sin descripción",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Información adicional de usuario y fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Creado por: ${tarea.usuarioCreacion ?? "N/A"}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              tarea.fechaCreacion != null
                                  // ? " ${puesto.fechaCreacion}"
                                  ? formatFechaHoraDate(tarea.fechaCreacion!)
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (tarea.fechaModificacion != null ||
                            tarea.fechaModificacion != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Modificado por: ${tarea.usuarioModificacion ?? "N/A"}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                tarea.fechaModificacion != null
                                    ? formatFechaHoraDate(
                                        tarea.fechaModificacion!,
                                      )
                                    : "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Editar",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => showBottomSheet(tarea.id),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _deletePasosTarea(tarea.id!),
                            ),
                          ],
                        ),
                        // ListTile(
                        //   title: Padding(
                        //     padding: EdgeInsets.symmetric(vertical: 5),
                        //     child: Text(
                        //       puesto.pasos,
                        //       style: TextStyle(fontSize: 20),
                        //     ),
                        //   ),
                        //   subtitle: Text("Tarea: ${puesto.nombre}"),
                        //   trailing: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       IconButton(
                        //         icon: Icon(Icons.edit, color: Colors.blue),
                        //         onPressed: () => showBottomSheet(puesto.id),
                        //       ),
                        //       IconButton(
                        //         icon: Icon(Icons.delete, color: Colors.red),
                        //         onPressed: () => _deletePasosTarea(puesto.id!),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
