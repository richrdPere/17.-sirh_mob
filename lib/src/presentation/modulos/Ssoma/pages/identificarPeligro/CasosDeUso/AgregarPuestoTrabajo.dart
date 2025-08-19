import 'package:flutter/material.dart';
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';

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
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(puesto.nombre, style: TextStyle(fontSize: 20)),
                    ),
                    subtitle: Text("Meta: ${puesto.areaMetaId}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showBottomSheet(puesto.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePasosTarea(puesto.id!),
                        ),
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
