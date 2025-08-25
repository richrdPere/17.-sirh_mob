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

class TipoControlOption {
  final int id;
  final String label;
  const TipoControlOption(this.id, this.label);
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
  bool _switchControlValue = false; // Estado inicial del switch

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();

  final TextEditingController _categoriaController = TextEditingController();

  String _stdController = "desactivado"; // Valor por defecto

  final List<TipoControlOption> _tipoControles = const [
    TipoControlOption(1, 'Eliminación'),
    TipoControlOption(2, 'Sustitución'),
    TipoControlOption(3, 'Ingeniería'),
    TipoControlOption(4, 'Administrativo'),
    TipoControlOption(5, 'EPP'),
  ];
  int? _selectedTipoControlId;  

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
        // tipo: _tipoController.text,
        tipo: _tipoControles[_selectedTipoControlId!].label.toString(),
        descripcion: _descripcionController.text,
        // categoria: _categoriaController.text,
        categoria: _tipoControles[_selectedTipoControlId!].label.toString(),
        std: _stdController,
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
        //tipo: _tipoController.text,
        tipo: _tipoControles[_selectedTipoControlId! - 1].label.toString(),
        descripcion: _descripcionController.text,
        // categoria: _categoriaController.text,
        categoria: _tipoControles[_selectedTipoControlId! - 1].label.toString(),
        std: _stdController,
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
  void showBottomSheet(int? id, bool isActive) async {
    if (id != null) {
      final existingData = _allControls.firstWhere((e) => e.id == id);

      // Cargamos los valores
      _nombreController.text = existingData.nombre;
      _tipoController.text = existingData.tipo;
      _categoriaController.text = existingData.categoria;
      _descripcionController.text = existingData.descripcion;
      _stdController = existingData.std;

      // Buscar el ID correcto segun el label guardado en la DB PARA CONTROLES
      final controlEncontrado = _tipoControles.firstWhere(
        (e) => e.label == existingData.tipo,
        orElse: () =>
            _tipoControles.first, // Evita crash si no encuentra coincidencia
      );
      // Guardamos el ID encontrado
      _selectedTipoControlId = controlEncontrado.id;
    } else {
      // Nuevo registro: limpiar selección
      _selectedTipoControlId = null;
      _nombreController.clear();
      _descripcionController.clear();
      _stdController = "";
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
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
                Row(
                  children: [
                    // Campo Nombre - Flexible para adaptarse
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Nombre",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Campo Meta - Select responsivo
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: _selectedTipoControlId,
                        items: _tipoControles
                            .map(
                              (tipo) => DropdownMenuItem<int>(
                                value: tipo.id,
                                child: Text(tipo.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedTipoControlId = val;
                          });
                          // opcional: sync con el controller si lo usas en otra parte
                          _tipoController.text = val?.toString() ?? '';
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Tipo/Categoria",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                Row(
                  children: [
                    // Campo Meta - Select responsivo
                    // Expanded(
                    //   flex: 2,
                    //   child: DropdownButtonFormField<int>(
                    //     value: _selectedTipoControlId,
                    //     items: _frecuenciasTareas
                    //         .map(
                    //           (tipo) => DropdownMenuItem<int>(
                    //             value: tipo.id,
                    //             child: Text(tipo.label),
                    //           ),
                    //         )
                    //         .toList(),
                    //     onChanged: (val) {
                    //       setModalState(() {
                    //         _selectedTipoFrecuenciaId = val;
                    //       });
                    //       // opcional: sync con el controller si lo usas en otra parte
                    //       _tipoController.text = val?.toString() ?? '';
                    //     },
                    //     decoration: InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       hintText: "Frecuencia",
                    //       contentPadding: const EdgeInsets.symmetric(
                    //         horizontal: 12,
                    //         vertical: 14,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 10),

                    // Campo Meta - Select responsivo
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("STD: "),
                          Switch(
                            //value: isActive,
                            value: _stdController == 'activado' ? true : false,
                            onChanged: (value) {
                              setModalState(() {
                                isActive = value;
                                _stdController = value
                                    ? "activado"
                                    : "desactivado";
                              });
                            },
                            activeColor: Colors
                                .white, // Color del círculo cuando está activado
                            activeTrackColor: Colors
                                .green, // Color de la pista cuando está activado
                            inactiveThumbColor: Colors
                                .white, // Color del círculo cuando está desactivado
                            inactiveTrackColor: Colors
                                .grey, // Color de la pista cuando está desactivado
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

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
                      _stdController = "";

                      // Ocultar Bottom sheet
                      Navigator.of(context).pop();
                      print("Agregar Control");
                    },
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        id == null ? "Agregar Control" : "Actualizar Control",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(title: const Text("Agregar Controles")),
      body: _allControls.isEmpty
          ? const Center(child: Text("No hay Medidas de Control registrados"))
          : ListView.builder(
              itemCount: _allControls.length,
              itemBuilder: (context, index) {
                final control = _allControls[index];
                return Card(
                  margin: EdgeInsets.all(15),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        control.nombre,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    subtitle: Text(
                      "Descripcion: ${control.descripcion}\nSTD: ${control.std}\nTipo/Categoria: ${control.tipo}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              showBottomSheet(control.id, _switchControlValue),
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
        onPressed: () => showBottomSheet(null, _switchControlValue),
        child: Icon(Icons.add),
      ),
    );
  }
}
