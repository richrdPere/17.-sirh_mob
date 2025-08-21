import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';

class AgregarPuestoTrabajo extends StatefulWidget {
  const AgregarPuestoTrabajo({super.key});

  @override
  State<AgregarPuestoTrabajo> createState() => _AgregarPuestoTrabajoState();
}

class _AgregarPuestoTrabajoState extends State<AgregarPuestoTrabajo> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todos los puestos
  List<PuestoTrabajo> _allPuestosTrabajo = [];
  bool _isLoading = true;

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshPuestoTrabajo();
  }

  // 5.- Funciones
  // Obtener
  void _refreshPuestoTrabajo() async {
    final data = await db.getPuestosTrabajo();

    setState(() {
      _allPuestosTrabajo = data;
      _isLoading = false;
    });
  }

  // Insertar
  Future<void> _addPasosTarea() async {
    await db.insertPuestoTrabajo(
      PuestoTrabajo(
        nombre: _nombreController.text,
        areaMetaId: int.parse(_metaController.text),
        descripcion: _descripcionController.text,
        std: _stdController.text,
        usuarioCreacion: 'admin',
        fechaCreacion: DateTime.now(),
        usuarioModificacion: '',
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPuestoTrabajo();
  }

  // Actualizar
  Future<void> _updatePasosTarea(int id) async {
    await db.updatePuestoTrabajo(
      PuestoTrabajo(
        id: id,
        nombre: _nombreController.text,
        areaMetaId: int.parse(_metaController.text),
        descripcion: _descripcionController.text,
        std: _stdController.text,
        usuarioCreacion: 'system', //  ficticio
        fechaCreacion: DateTime(2025, 01, 01), //  ficticio
        usuarioModificacion: 'admin_update', //  ficticio para update
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshPuestoTrabajo();
  }

  // Eliminar
  void _deletePasosTarea(int id) async {
    await db.deletePuestoTrabajo(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Puesto de trabajo eliminado."),
      ),
    );
    _refreshPuestoTrabajo();
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
      final existingData = _allPuestosTrabajo.firstWhere((e) => e.id == id);
      _nombreController.text = existingData.nombre;
      _metaController.text = existingData.areaMetaId.toString();
      _descripcionController.text = existingData.descripcion;
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
              controller: _metaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Meta",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Descripción",
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
                  _metaController.text = "";
                  _descripcionController.text = "";
                  _stdController.text = "";

                  // Actualizar Lista de Puestos
                  _refreshPuestoTrabajo();

                  // Ocultar Bottom sheet
                  Navigator.of(context).pop();
                  print("Agregar Puesto");
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Puesto" : "Actualizar Puesto",
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
              itemCount: _allPuestosTrabajo.length,
              itemBuilder: (context, index) {
                final puesto = _allPuestosTrabajo[index];
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
                          puesto.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
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
                              "Meta: ${puesto.areaMetaId}",
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
                              "STD: ${puesto.std}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Descripción
                        Text(
                          puesto.descripcion.isNotEmpty
                              ? puesto.descripcion
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
                              "Creado por: ${puesto.usuarioCreacion ?? "N/A"}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              puesto.fechaCreacion != null
                                  // ? " ${puesto.fechaCreacion}"
                                  ? formatFechaHoraDate(puesto.fechaCreacion)
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (puesto.fechaModificacion != null ||
                            puesto.fechaModificacion != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Modificado por: ${puesto.usuarioModificacion ?? "N/A"}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                puesto.fechaModificacion != null
                                    ? formatFechaHoraDate(
                                        puesto.fechaModificacion,
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
                              onPressed: () => showBottomSheet(puesto.id),
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
                              onPressed: () => _deletePasosTarea(puesto.id!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // child: ListTile(
                  //   title: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 5),
                  //     child: Text(
                  //       puesto.nombre,
                  //       style: TextStyle(fontSize: 20),
                  //     ),
                  //   ),
                  //   subtitle: Text("Meta: ${puesto.areaMetaId}"),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showBottomSheet(null),
          _refreshPuestoTrabajo()  
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
