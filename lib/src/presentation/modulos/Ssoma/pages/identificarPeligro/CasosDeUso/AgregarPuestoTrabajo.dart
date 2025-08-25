import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Database
import 'package:sirh_mob/src/data/datasource/local/db_sqlite/database_ssoma.dart';

// Modelo
import 'package:sirh_mob/src/domain/models/ssoma_models/PuestoTrabajo.dart';

class MetaOption {
  final int id;
  final String label;
  const MetaOption(this.id, this.label);
}

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
  bool _switchValue = false; // Estado inicial del switch

  final List<MetaOption> _metas = const [
    MetaOption(289, 'Meta 289'),
    MetaOption(79, 'Meta 79'),
    MetaOption(38, 'Meta 38'),
    MetaOption(45, 'Meta 45'),
  ];

  // 3.- Campos
  final TextEditingController _nombreController = TextEditingController();

  final TextEditingController _metaController = TextEditingController();
  int? _selectedMetaId;
  // final ValueChanged<String?> onMetaChanged = null;

  final TextEditingController _descripcionController = TextEditingController();
  String _stdController = "desactivado"; // Valor por defecto

  // 4.- Inicializar
  @override
  void initState() {
    super.initState();
    _nombreController.addListener(() {
      // Forzar a mayúsculas
      _nombreController.value = _nombreController.value.copyWith(
        text: _nombreController.text.toUpperCase(),
        selection: _nombreController.selection,
      );
    });
    _refreshPuestoTrabajo();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _metaController.dispose();
    super.dispose();
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
        // areaMetaId: int.parse(_metaController.text),
        areaMetaId: _selectedMetaId!,
        descripcion: _descripcionController.text,
        std: _stdController,
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
        // areaMetaId: int.parse(_metaController.text),
        areaMetaId: _selectedMetaId!,
        descripcion: _descripcionController.text,
        std: _stdController,
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

  // =============================
  // 6.- FUNCIONES AUXILIARES
  // =============================
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

  // Convertir a mayuscula
  String toUpperCaseText(String value) {
    return value.toUpperCase();
  }

  // =============================
  // 7.- MODAL PARA AGREGAR / EDITAR
  // =============================
  void showBottomSheet(int? id, bool isActive) async {
    if (id != null) {
      final existingData = _allPuestosTrabajo.firstWhere((e) => e.id == id);
      _nombreController.text = existingData.nombre;
      // _metaController.text = existingData.areaMetaId.toString();
      _selectedMetaId = existingData.areaMetaId; // << importar este valor
      _descripcionController.text = existingData.descripcion;
      _stdController = existingData.std;
    } else {
      // Nuevo registro: limpiar selección
      _selectedMetaId = null;
      _nombreController.clear();
      _descripcionController.clear();
      _stdController = "desactivado";
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
                        value: _selectedMetaId,
                        items: _metas
                            .map(
                              (meta) => DropdownMenuItem<int>(
                                value: meta.id,
                                child: Text(meta.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setModalState(() {
                            _selectedMetaId = val;
                          });
                          // opcional: sync con el controller si lo usas en otra parte
                          _metaController.text = val?.toString() ?? '';
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Meta",
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("STD: "),
                    Switch(
                      value: _stdController == 'activado' ? true : false,
                      onChanged: (value) {
                        setModalState(() {
                          isActive = value;
                          _stdController = value ? "activado" : "desactivado";
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
                      _stdController = "desactivado";

                      // Actualizar Lista de Puestos
                      _refreshPuestoTrabajo();

                      // Ocultar Bottom sheet
                      Navigator.of(context).pop(true);
                      
                    },
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        id == null ? "Agregar Puesto" : "Actualizar Puesto",
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
      appBar: AppBar(title: const Text("Agregar Puestos")),
      body: _allPuestosTrabajo.isEmpty
          ? const Center(child: Text("No hay Puestos de Trabajo registrados"))
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
                              "${puesto.std}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
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
                              onPressed: () =>
                                  showBottomSheet(puesto.id, _switchValue),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showBottomSheet(null, _switchValue),
          _refreshPuestoTrabajo(),
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
