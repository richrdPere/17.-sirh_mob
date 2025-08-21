import 'package:flutter/material.dart';
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/Control.dart';
import 'package:sirh_mob/src/domain/models/ssoma_models/Tarea.dart';

class ControlEntry {
  ControlType type;
  String description;

  ControlEntry({required this.type, required this.description});

  Map<String, dynamic> toJson() => {
    'type': type.label,
    'description': description,
  };
}

enum ControlType { eliminacion, sustitucion, ingenieria, administrativo, epp }

extension ControlTypeText on ControlType {
  String get label {
    switch (this) {
      case ControlType.eliminacion:
        return 'Eliminación';
      case ControlType.sustitucion:
        return 'Sustitución';
      case ControlType.ingenieria:
        return 'Ingeniería';
      case ControlType.administrativo:
        return 'Administrativo';
      case ControlType.epp:
        return 'EPP';
    }
  }
}

class AgregarControl extends StatefulWidget {
  const AgregarControl({super.key});

  @override
  State<AgregarControl> createState() => _AgregarControlState();
}

class _AgregarControlState extends State<AgregarControl> {
  // 1.- Instancia a la DB Ssoma
  final db = DatabaseSsoma.instance;

  // 2.- Todos los puestos
  List<Control> _allControls = [];
  bool _isLoading = true;

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _stdController = TextEditingController();

  // final List<ControlEntry> _controles = [
  //   ControlEntry(type: ControlType.epp, description: ''),
  // ];

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _refreshControles();
  }

  // 5.- Funciones
  // Obtener
  void _refreshControles() async {
    final data = await db.getControles();

    setState(() {
      _allControls = data;
      _isLoading = false;
    });
  }

  // Insertar
  Future<void> _addControles() async {
    await db.insertControl(
      Control(
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        descripcion: _descripcionController.text,
        categoria: _categoriaController.text,
        std: _stdController.text,
        usuarioCreacion: 'admin',
        fechaCreacion: DateTime.now(),
        usuarioModificacion: '',
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshControles();
  }

  // Actualizar
  Future<void> _updateControl(int id) async {
    await db.updateControl(
      Control(
        id: id,
        nombre: _nombreController.text,
        tipo: _tipoController.text,
        descripcion: _descripcionController.text,
        categoria: _categoriaController.text,
        std: _stdController.text,
        usuarioCreacion: 'system', //  ficticio
        fechaCreacion: DateTime(2025, 01, 01), //  ficticio
        usuarioModificacion: 'admin_update', //  ficticio para update
        fechaModificacion: DateTime.now(),
      ),
    );
    _refreshControles();
  }

  // Eliminar
  void _deleteControl(int id) async {
    await db.deleteControl(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Control Eliminado."),
      ),
    );
    _refreshControles();
  }

  // 6.- Form Tarea
  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = _allControls.firstWhere((e) => e.id == id);
      _nombreController.text = existingData.nombre;
      _tipoController.text = existingData.tipo;
      _categoriaController.text = existingData.categoria;
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
              controller: _tipoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tipo",
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
              controller: _categoriaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Categoria",
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
                    await _addControles();
                  }

                  if (id != null) {
                    await _updateControl(id);
                  }

                  _nombreController.text = "";
                  _tipoController.text = "";
                  _categoriaController.text = "";
                  _descripcionController.text = "";
                  _stdController.text = "";

                  // Ocultar Bottom sheet
                  Navigator.of(context).pop();
                  print("Agregar Control");
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Control" : "Actualizar Control",
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
      appBar: AppBar(title: const Text("Agregar Controles")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allControls.length,
              itemBuilder: (context, index) {
                final control = _allControls[index];
                return Card(
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(control.nombre, style: TextStyle(fontSize: 20)),
                    ),
                    subtitle: Text("Descripcion: ${control.descripcion}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showBottomSheet(control.id),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteControl(control.id!),
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
